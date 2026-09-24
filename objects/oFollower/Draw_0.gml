var _targetHeight = 48;
var _sprHeight = sprite_get_height(sprite);
var _scale = 1;
if (_sprHeight > _targetHeight) {
    _scale = _targetHeight / _sprHeight;
}
draw_sprite_ext(sprite, 0, x, y, image_xscale * _scale, image_yscale * _scale, 0, c_white, 1);
