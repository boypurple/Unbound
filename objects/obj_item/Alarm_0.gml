/*
That part looks if there is another obj_item colliding with that one, if yes, it will add its own
list to the other one. (The other id is ooo, if none has been found ooo = noone)
*/

var ooo = instance_place(x, y, obj_item);

if (ooo !=noone)
{
var size, count, iii, qqq, ppp, t_qt;

size = ds_list_size(List[0]);

    repeat(size)
    {
    iii = ds_list_find_value(List[0], size-1);
    qqq = ds_list_find_value(List[1], size-1);
    ds_list_delete(List[0], size-1);
    ds_list_delete(List[1], size-1);
    
        with(ooo)
        {
        ppp = ds_list_find_index(List[0], iii);
            
            if (ppp == -1)
            {
            ds_list_add(List[0], iii);
            ds_list_add(List[1], qqq);
            }
            else
            {
            t_qt = ds_list_find_value(List[1], ppp);
            ds_list_replace(List[1], ppp, qqq+t_qt);
            }
        
        }
        
    size = ds_list_size(List[0]);
    }
    
    with(ooo)
    {
    event_user(0);
    }

ds_list_destroy(List[0]);
ds_list_destroy(List[1]);
instance_destroy();
}