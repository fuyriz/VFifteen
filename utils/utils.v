module utils

pub fn delete (mut arr []u8, index int) []u8 {
    if index < 0 || index >= arr.len {
        return arr
    }

    mut new_arr := arr[..index]
    new_arr << arr[index+1..]
    return new_arr
}