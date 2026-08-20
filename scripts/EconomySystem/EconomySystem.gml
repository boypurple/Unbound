/// @desc Money system — global.coins is the bank (ATM) balance, global.cash is cash on hand.

function AddBankFunds(_amount)
{
    global.coins += _amount;
}

function DepositToBank(_amount)
{
    var _real_amount = clamp(_amount, 0, global.cash);
    global.cash  -= _real_amount;
    global.coins += _real_amount;
    return _real_amount;
}

function WithdrawFromBank(_amount)
{
    var _real_amount = clamp(_amount, 0, global.coins);
    global.coins -= _real_amount;
    global.cash  += _real_amount;
    return _real_amount;
}

function CanAffordCash(_amount)
{
    return global.cash >= _amount;
}

function SpendCash(_amount)
{
    if (!CanAffordCash(_amount)) return false;
    global.cash -= _amount;
    return true;
}

function ApplyDeathPenalty()
{
    global.cash = floor(global.cash * 0.5);
}

// ------------------------------------------------------------
// SHOP PRICE DATABASE
//   global.shop_price_database is a struct keyed by ItemID string
//   (must match an id in items_db.csv) → buy price (real).
//   Read from the Included Files bundle, same pattern as
//   LoadItemDatabase()/LoadEquipmentDatabase(). Call once during
//   game init (oUi Create, alongside those two).
// ------------------------------------------------------------
function LoadShopPriceDatabase()
{
    global.shop_price_database = {};

    if (!file_exists("shop_prices.csv"))
    {
        show_debug_message("[EconomySystem] ERROR: shop_prices.csv not found!");
        return;
    }

    var _grid        = load_csv("shop_prices.csv");
    var _grid_height = ds_grid_height(_grid);

    // Row 0 = column headers, row 1 = type hints, row 2+ = data (matches items_db.csv/equipment.csv)
    for (var i = 2; i < _grid_height; i++)
    {
        var _id    = ds_grid_get(_grid, 0, i); // string, must exist in items_db.csv
        var _price = real(ds_grid_get(_grid, 1, i));

        global.shop_price_database[$ _id] = _price;
    }

    ds_grid_destroy(_grid);
}

function GetShopPrice(_item_id)
{
    return global.shop_price_database[$ _item_id] ?? 0;
}

function OpenShopUI(_item_ids = undefined)
{
    if (instance_exists(oShop_UI)) return;

    var _inst = instance_create_layer(0, 0, global.Layer_UI, oShop_UI);
    if (_item_ids != undefined) {
        _inst.shop_items = _item_ids;
    }
}

function OpenATMUI(_unused = undefined)
{
    if (instance_exists(oATM_UI)) return;
    instance_create_layer(0, 0, global.Layer_UI, oATM_UI);
}
