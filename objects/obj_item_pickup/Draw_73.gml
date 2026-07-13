if (instance_exists(obj_player) && place_meeting(x, y, obj_player)) 
{
    draw_set_font(fnMother3); 
	
	var _text = "Press Space";
    var _pad_x = 6; // Jarak isi kotak ke kanan-kiri teks (padding)
    var _pad_y = 4; // Jarak isi kotak ke atas-bawah teks
    
    // Hitung lebar dan tinggi teks dalam satuan pixel
    var _text_w = string_width(_text);
    var _text_h = string_height(_text);
    
    // Tentukan titik koordinat teks
    var _text_x = x;
    var _text_y = bbox_top - 16;
    
    // 2. HITUNG AREA KOTAK BACKGROUND
    // Karena halign = center dan valign = bottom, kita hitung dari titik tengah bawah
    var _x1 = _text_x - (_text_w / 2) - _pad_x;
    var _y1 = _text_y - _text_h - _pad_y;
    var _x2 = _text_x + (_text_w / 2) + _pad_x;
    var _y2 = _text_y + _pad_y;
    
    // 3. GAMBAR BACKGROUND TRANSPARAN
    draw_set_alpha(0.6); // Set transparansi (0.0 gaib, 1.0 pekat). 0.6 = 60% hitam
    draw_set_colour(c_black);
    
    // Menggunakan draw_roundrect agar ujung kotaknya sedikit tumpul/estetik
    draw_roundrect(_x1, _y1, _x2, _y2, false); 
    
    // 4. RESET ALPHA & RESET WARNA UNTUK MENGGAMBAR TEKS
    // WAJIB diganti ke 1.0 lagi agar teksnya tidak ikut transparan!
    draw_set_alpha(1.0); 
    draw_set_colour(c_yellow);
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    
    // 5. GAMBAR TEKS DI ATAS KOTAK
    draw_text(_text_x, _text_y, _text);
    
    // Selalu reset warna ke putih bawaan di akhir script agar tidak merusak objek lain
    draw_set_colour(c_white);
}