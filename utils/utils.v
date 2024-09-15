module utils

pub fn delete (mut arr []u8, index int) []u8 {
    if index < 0 || index >= arr.len {
        return arr
    }

    mut new_arr := unsafe{arr[..index]}
    new_arr << arr[index+1..]
    return new_arr
}

pub fn count_inversions(puzzle [4][4]u8) int {
    mut inversions := 0
    mut flat_puzzle := []int{}

    for row in puzzle {
        for value in row {
            if value != 0 {
                flat_puzzle << value
            }
        }
    }
    for i in 0..flat_puzzle.len {
        for j in i + 1..flat_puzzle.len {
            if flat_puzzle[i] > flat_puzzle[j] {
                inversions++
            }
        }
    }
    return inversions
}

pub fn is_solvable(puzzle [4][4]u8) bool {
    inversions := count_inversions(puzzle)
    mut empty_tile_row := 0
    for i in 0..4 {
        for j in 0..4 {
            if puzzle[i][j] == 0 {
                empty_tile_row = i + 1
            }
        }
    }
    if (inversions % 2 == 0 && empty_tile_row % 2 == 0) || (inversions % 2 != 0 && empty_tile_row % 2 != 0) {
        return true
    }
    return false
}

pub fn pad(n u64, len u8) string {
    mut num_str := n.str()
    for num_str.len < int(len) {
        num_str = '0' + num_str
    }
    return num_str
}

@[inline]
pub fn min(a u16, b u16) u16 {
    if a < b {return a}
    return b
} 