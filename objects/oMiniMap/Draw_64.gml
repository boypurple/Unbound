if(global.gamePaused && global.gameMenu && !global.config && !global.partyMenu)    
{
    /// @desc Draw Background
    if(!surface_exists(surfMinimapBg))
    {
        RefreshMapBG()
    }
    draw_surface(surfMinimapBg, x, y)
    
    //Draw Entities
    if(!surface_exists(surfMinimapEntities)) 
    {
        surfMinimapEntities = surface_create(w, h)
    }
    surface_set_target(surfMinimapEntities)
        draw_clear_alpha(c_black, 0)
        with(pEntity)
        {
            if(entityOnMinimap == true)
            {
                draw_sprite_ext
                (
                    sPixel,
                    0,
                    x / 4,
                    y / 4,
                    1,
                    1,
                    0,
                    c_red,
                    1
                )
            }
        }
    surface_reset_target()
    draw_surface(surfMinimapEntities, x, y)
    
    //Draw camera position box
    var _vX = camera_get_view_x(view_camera[0]) / 4
    var _vY = camera_get_view_y(view_camera[0]) / 4
    draw_sprite_stretched 
    (
        sMinimapView,
        0,
        x + _vX,
        y + _vY,
        640 / 4,
        360 / 4
    )
    
    //Draw Border
    draw_sprite_stretched(sMinimapBox, 0, x - 6, y - 6, w + 12, h + 12)
}