const cds = require('@sap/cds');

module.exports = cds.service.impl(async function () {

  const { StockMovements, StockLevels, Products, Warehouses } = this.entities;
  const geoAPI = await cds.connect.to('GEO_API');



  this.before(['CREATE', 'UPDATE'], 'StockLevels.drafts', async (req) => {

    const { ID } = req.data;

    const row = await SELECT.one.from(req.target).columns('Product_ID', 'Warehouse_ID').where({ ID });

    const Product_ID = req.data.Product_ID ?? row?.Product_ID;
    const Warehouse_ID = req.data.Warehouse_ID ?? row?.Warehouse_ID;

    if (!Product_ID || !Warehouse_ID) return;

    const duplicate = await SELECT.one.from(req.target).where({ Product_ID, Warehouse_ID, ID: { '!=': ID } });

    if (duplicate) {
      return req.reject('Warehouse already there for this product');
    }
  });

  this.before('CREATE', 'StockLevels', async (req) => {

    const { Product_ID, Warehouse_ID } = req.data;

    if (!Product_ID) {
      return req.reject('Product is required');
    }

    if (!Warehouse_ID) {
      return req.reject('Warehouse is required');
    }


    const existing = await SELECT.one.from(StockLevels).where({
      Product_ID,
      Warehouse_ID
    });

    if (existing) {
      return req.reject('Stock already exists for this Product and Warehouse. Please update the existing record.');
    }


    const currentStock = Number(req.data.CurrentStock ?? 0);
    const reservedStock = Number(req.data.ReservedStock ?? 0);

    if (currentStock < 0) {
      return req.reject('Current Stock cannot be negative');
    }

    if (reservedStock < 0) {
      return req.reject('Reserved Stock cannot be negative');
    }


    const product = await SELECT.one
      .from(Products)
      .columns('MinStockLevel', 'MaxStockLevel')
      .where({ ID: Product_ID });

    if (!product) {
      return req.reject('Product not found');
    }

    if (currentStock < product.MinStockLevel) {
      return req.reject(`Current Stock cannot be below Min Stock Level (${product.MinStockLevel})`
      );
    }

    if (currentStock > product.MaxStockLevel) {
      return req.reject(`Current Stock cannot exceed Max Stock Level (${product.MaxStockLevel})`);
    }

  });

  this.before('UPDATE', 'StockLevels', async (req) => {

    const { ID } = req.data;

    const currentStock = Number(req.data.CurrentStock ?? 0);
    const reservedStock = Number(req.data.ReservedStock ?? 0);


    if (currentStock < 0) {
      req.reject('Current Stock cannot be negative');
    }

    if (reservedStock < 0) {
      req.reject('Reserved Stock cannot be negative');
    }

    let productId = req.data.Product_ID;

    if (!productId && ID) {
      const existing = await SELECT.one
        .from(StockLevels)
        .columns('Product_ID')
        .where({ ID });

      productId = existing?.Product_ID;
    }

    if (!productId) {
      return req.reject('Product is required');
    }


    const product = await SELECT.one
      .from(Products)
      .columns('MinStockLevel', 'MaxStockLevel')
      .where({ ID: productId });

    if (!product) {
      return req.reject('Product not found');
    }

    if (currentStock < product.MinStockLevel) {
      return req.reject(
        `Current Stock cannot be below Min Stock Level (${product.MinStockLevel})`
      );
    }

    if (currentStock > product.MaxStockLevel) {
      return req.reject(`Current Stock cannot exceed Max Stock Level (${product.MaxStockLevel})`
      );
    }

  });

  this.before('NEW', 'StockMovements.drafts', (req) => {

    if (!req.data.MovementDate) {
      req.data.MovementDate = new Date().toISOString().slice(0, 10);
    }

    if (!req.data.MovedBy) {
      req.data.MovedBy = req.user?.id || 'System';
    }
  });

  this.before('CREATE', 'StockMovements', (req) => {

    const qty = Number(req.data.Quantity);

    if (qty <= 0) {
      return req.reject('Quantity must be greater than 0');
    }
  });


this.before('DELETE', 'StockMovements', async (req) => {
  const ID = req.params?.[0]?.ID ?? req.data?.ID;
  const row = await SELECT.one.from(StockMovements).columns('MovementType').where({ ID });

  if (row?.MovementType) {
    return req.reject(400, 'Processed movements cannot be deleted');
  }
});

this.before('UPDATE', 'StockMovements', async (req) => {
  const ID = req.params?.[0]?.ID ?? req.data?.ID;

  const existing = await SELECT.one
    .from(StockMovements)
    .columns('MovementType')
    .where({ ID });

  if (existing?.MovementType) {
    return req.reject(400, 'Processed movements cannot be edited');
  }

  if ('Quantity' in req.data) {
    const qty = Number(req.data.Quantity);
    if (qty <= 0) {
      return req.reject(400, 'Quantity must be greater than 0');
    }
  }
});

  this.after('READ', 'StockLevels', (data) => {

    const rows = Array.isArray(data) ? data : [data];

    for (const item of rows) {

      const current = item.CurrentStock || 0;
      const reserved = item.ReservedStock || 0;

      item.AvailableStock = current - reserved;
    }
  });

  this.on('getLowStockAlerts', async () => {

    const data = await SELECT.from(StockLevels)
      .columns(
        'ID',
        'CurrentStock',
        'ReservedStock',
        'Product.Name as ProductName',
        'Product.MinStockLevel as MinStockLevel',
        'Warehouse.Name as WarehouseName'
      )
      .where('CurrentStock < Product.MinStockLevel');

    return data;
  });

  this.on('getAvailableStock', async (req) => {

    const { productID, warehouseID } = req.data;

    const stock = await SELECT.one.from(StockLevels)
      .columns('CurrentStock', 'ReservedStock')
      .where({
        Product_ID: productID,
        Warehouse_ID: warehouseID
      });

    if (!stock) {
      return 0;
    }

    return (stock.CurrentStock || 0) - (stock.ReservedStock || 0);
  });

  this.on('goodsReceipt', 'StockMovements', async (req) => {
    const { ID } = req.params[0];
    const movement = await SELECT.one.from(StockMovements).where({ ID });

    if (!movement) return req.error(404, 'Movement not found');
    if (movement.ActionRequested !== 'GoodsReceipt') return req.error(400, 'Only Goods Receipt action is allowed');
    if (movement.MovementType) return req.error(400, `Already processed as ${movement.MovementType}`);

    const product = await SELECT.one.from(Products).where({ ID: movement.Product_ID });
    const stock = await SELECT.one.from(StockLevels).where({ Product_ID: movement.Product_ID, Warehouse_ID: movement.ToWarehouse_ID });
    const newStock = (stock?.CurrentStock || 0) + movement.Quantity;

    if (newStock > product.MaxStockLevel) return req.error(400, `Max stock exceeded for ${product.Name}`);

    if (stock) {
      await UPDATE(StockLevels).set({ CurrentStock: { '+=': movement.Quantity } }).where({ ID: stock.ID });
    } else {
      await INSERT.into(StockLevels).entries({ Product_ID: movement.Product_ID, Warehouse_ID: movement.ToWarehouse_ID, CurrentStock: movement.Quantity, ReservedStock: 0 });
    }

    await UPDATE(StockMovements).set({ MovementType: 'GoodsReceipt' }).where({ ID });

    try {
      const alerts = await this.send('getLowStockAlerts');
      if (Array.isArray(alerts) && alerts.length > 0) req.notify(`${alerts.length} Low Stock Alert(s) found`);
    } catch (e) { console.error("Alert service failed"); }

    req.notify('Goods Receipt completed');
  });

  this.on('goodsIssue', 'StockMovements', async (req) => {
    const { ID } = req.params[0];
    const movement = await SELECT.one.from(StockMovements).where({ ID });

    if (!movement) return req.error(404, 'Movement not found');
    if (movement.ActionRequested !== 'GoodsIssue') return req.error(400, 'Only Goods Issue action is allowed');
    if (movement.MovementType) return req.error(400, `Already processed as ${movement.MovementType}`);

    const stock = await SELECT.one.from(StockLevels).where({ Product_ID: movement.Product_ID, Warehouse_ID: movement.FromWarehouse_ID });
    if (!stock) return req.error(404, 'Stock not found');

    const available = (stock.CurrentStock || 0) - (stock.ReservedStock || 0);
    if (available < movement.Quantity) return req.error(400, 'Insufficient stock');

    await UPDATE(StockLevels).set({ CurrentStock: { '-=': movement.Quantity } }).where({ ID: stock.ID });
    await UPDATE(StockMovements).set({ MovementType: 'GoodsIssue' }).where({ ID });

    try {
      const alerts = await this.send('getLowStockAlerts');
      if (Array.isArray(alerts) && alerts.length > 0) {
        const alertMessages = alerts.map(a => `${a.ProductName} in ${a.WarehouseName} | Current: ${a.CurrentStock} | Min: ${a.MinStockLevel}`);
        req.notify(`Low Stock Alerts:\n${alertMessages.join('\n')}`);
      }
    } catch (e) { console.error("Alert service failed"); }

    req.notify('Goods Issue completed');
  });

  this.on('stockTransfer', 'StockMovements', async (req) => {
    const { ID } = req.params[0];
    const movement = await SELECT.one.from(StockMovements).where({ ID });

    if (!movement) return req.error(404, 'Movement not found');
    if (movement.ActionRequested !== 'Transfer') return req.error(400, 'Only Stock Transfer action is allowed');
    if (movement.MovementType) return req.error(400, `Already processed as ${movement.MovementType}`);
    if (movement.FromWarehouse_ID === movement.ToWarehouse_ID) return req.error(400, 'Source and destination warehouse cannot be same');

    const source = await SELECT.one.from(StockLevels).where({ Product_ID: movement.Product_ID, Warehouse_ID: movement.FromWarehouse_ID });
    if (!source) return req.error(404, 'Source stock not found');

    const available = (source.CurrentStock || 0) - (source.ReservedStock || 0);
    if (available < movement.Quantity) return req.error(400, 'Insufficient stock');

    const target = await SELECT.one.from(StockLevels).where({ Product_ID: movement.Product_ID, Warehouse_ID: movement.ToWarehouse_ID });

    await UPDATE(StockLevels).set({ CurrentStock: { '-=': movement.Quantity } }).where({ ID: source.ID });
    if (target) {
      await UPDATE(StockLevels).set({ CurrentStock: { '+=': movement.Quantity } }).where({ ID: target.ID });
    } else {
      await INSERT.into(StockLevels).entries({ Product_ID: movement.Product_ID, Warehouse_ID: movement.ToWarehouse_ID, CurrentStock: movement.Quantity, ReservedStock: 0 });
    }

    await UPDATE(StockMovements).set({ MovementType: 'Transfer' }).where({ ID });

    try {
      const alerts = await this.send('getLowStockAlerts');
      if (  Array.isArray(alerts) && alerts.length > 0) req.notify(`${alerts.length} Low Stock Alert(s) found`);
    } catch (e) { console.error("Alert service failed"); }

    req.notify('Stock Transfer completed');
  });

  this.before(['CREATE', 'UPDATE'], 'Warehouses', async (req) => {

    const location = req.data.Location;

    if (!location) {
      return req.reject(400, 'Location is required');
    }

    const response = await geoAPI.send({
      method: 'GET',
      path: `/search?q=${encodeURIComponent(location)}&format=json&limit=1`,
      headers: { 'User-Agent': 'InventoryApp/1.0' }
    });

    if (!response || response.length === 0) {
      return req.reject(400, 'Please enter a proper warehouse location.');
    }

    const item = response[0];

    if (!item.display_name.toLowerCase().includes(location.toLowerCase())) {
      return req.reject(400, 'Please enter a valid warehouse location.');
    }

  });



  this.on('checkLocation', Warehouses, async (req) => {

    const { ID } = req.params[0];

    const warehouse = await SELECT.one
      .from('Inventory.Warehouses')
      .where({ ID });

    if (!warehouse) return req.reject(404, 'Warehouse not found');

    const location = warehouse.Location;
    if (!location) return req.reject(400, 'Location missing');

    let response;
    try {
      response = await geoAPI.send({
        method: 'GET',
        path: `/search?q=${encodeURIComponent(location)}&format=json&limit=1`,
        headers: { 'User-Agent': 'InventoryApp/1.0' }
      });
    } catch (err) {
      console.error('GEO API error:', err);
      return req.reject('Failed to reach location service');
    }

    if (!response || response.length === 0) {
      return req.reject(400, `Location "${location}" not found.`);
    }

    const item = response[0];
    const lat = parseFloat(item.lat);
    const lng = parseFloat(item.lon);
    const mapUrl = `https://www.google.com/maps?q=${lat},${lng}`;


    await cds.db.run(
      UPDATE('Inventory.Warehouses')
        .set({ Latitude: lat, Longitude: lng, MapUrl: mapUrl })
        .where({ ID })
    );

    req.notify(200, `Location verified: ${item.display_name}`);

    return { lat, lng, mapUrl };
  });



  this.on('checkPendingStockMovements', async () => {

    const pending = await SELECT.from(StockMovements)
      .where({ MovementType: null });

    if (pending.length > 0) {
      return `${pending.length} pending stock movement(s) found`;
    }

    return 'No pending stock movements';
  });



})









