_event = 0;
var _item_data = GetItemFromDatabase(item_id_pickup)
if (_item_data != undefined) 
{
    sprite_index = _item_data.icon;
    image_index  = _item_data.image_index; // Kritis: Mengambil frame yang benar dari CSV
    image_speed  = 0;                      // Kritis: Menghentikan animasi agar frame tidak berubah
}