/* [主体参数] */
// 主体长度
plate_length = 3800;
// 主体宽度
plate_width = 2670;
// 主体高度
plate_thickness = 500;

/* [泳池参数] */
// 泳池长度
pool_length = 2000;
// 泳池宽度
pool_width = 1940;
// 泳池深度
pool_depth = 300;
// 泳池右侧边距
pool_margin = 800;

// 地垫宽度
mat_thickness = 120;
// 地垫高度
mat_height = 40;

/* [地砖参数] */
tile_size = 200;
// 缝隙宽度
groove_width = 8;
// 缝隙深度
groove_depth = 8;

/* [矮墙参数] */
// 矮墙高度
stub_wall_height = 300;

// 外侧倒角墙下侧高度
outer_wall_height = 300;

/* [楼梯参数] */
// 门底部到地板的距离 (450mm)
door_bottom_height = 450 - 90;
// 每级台阶高度 (总高度除以3级)
step_height = door_bottom_height / 3; // 150mm per step
step_depth = 300; // 每级台阶深度


/* [计算参数] */
pool_x_start = plate_length - pool_margin - pool_length;
pool_x_end = pool_x_start + pool_length;
pool_y_start = (plate_width - pool_width)/2;
pool_y_end = pool_y_start + pool_width;

// 墙体厚度
wall_thickness = 100;
// 总高度
total_height = 2600;
groove_spacing = 80; // 装饰线条间距
groove_width_wall = 2; // 线条宽度
groove_depth_wall = 20; // 线条深度

module floor_with_pool() {
    translate([0, wall_thickness, 0])  {
        difference() {
            // 地板基体
            cube([plate_length, plate_width, plate_thickness]);

            // 同时挖除泳池和地砖缝隙
            union() {
                // 挖除泳池
                translate([pool_x_start, pool_y_start, plate_thickness - pool_depth])
                    cube([pool_length, pool_width, pool_depth + 1]);

                // 挖除地砖缝隙
                tile_grooves();
            }
        }
    }

    // 添加泳池防护栏
    translate([0, wall_thickness, plate_thickness]) {
        // 上边缘防护（北侧）- 宽度40mm，高度10mm
        translate([pool_x_start - mat_thickness, pool_y_end, 0])
            cube([pool_length + 2 * mat_thickness, mat_thickness, mat_height]); // 长度延伸覆盖左右角落

        // 下边缘防护（南侧）
        translate([pool_x_start - mat_thickness, pool_y_start - mat_thickness, 0])
            cube([pool_length +  2 * mat_thickness, mat_thickness, mat_height]);

        // 左边缘防护（西侧）
        translate([pool_x_start - mat_thickness, pool_y_start - mat_thickness, 0])
            cube([mat_thickness, pool_width +  2 * mat_thickness, mat_height]); // 高度延伸覆盖上下角落

        // 右边缘防护（东侧）
        translate([pool_x_end, pool_y_start - mat_thickness, 0])
            cube([mat_thickness, pool_width + 2 * mat_thickness, mat_height]);
    }

}

module wall_with_door() {
    door_width = 600; // 定义门洞的宽度
    door_height = total_height - plate_thickness; // 门洞高度与墙同高
    door_offset = 150 + wall_thickness; // 修改为从墙角开始偏移50单位加上墙体厚度

    difference() {
        // 墙壁主体
        translate([plate_length, 0, 0]) {
            cube([wall_thickness, 1400, total_height]);
        }

        // 挖门洞：从墙角偏移50单位
        translate([
                plate_length,
                door_offset, // Y轴从墙角偏移50单位
                plate_thickness  + 450// 从地面开始
            ]) {
            cube([
                wall_thickness,
                door_width,
                1200 // 使用与墙同高的门洞
                ]);
        }

        // 新增：水平装饰刻线（每隔80mm）
        for(z = [0 : groove_spacing : total_height - plate_thickness]) {
            translate([
                        plate_length , // 从外表面向内雕刻
                wall_thickness, // 确保覆盖整个宽度
                        plate_thickness + z - groove_width_wall/2 // 垂直居中刻线
                ]) {
                cube([
                        35, // 刻线深度（带容差）
                        1400, // 覆盖整个墙面宽度
                        groove_width_wall // 刻线高度
                    ]);
            }
        }
    }

}


// 楼梯
module steps() {
    // 计算门到泳池距离和楼梯尺寸
    door_to_pool_distance = plate_length - pool_x_end; // 门到泳池的距离 (800mm)
    steps_total_size = door_to_pool_distance * 0.78; // 楼梯总长度 (600mm) - 保持原来的长度计算
    door_width = 600; // 门的宽度
    
    // 定义三级台阶的宽度（Y方向），保持长度（X方向）按原来的逻辑递减
    step_width_1 = door_width + 450; // 第一级台阶（最低级，最大）
    step_width_2 = door_width + 300;  // 第二级台阶（中间级）
    step_width_3 = door_width + 150; // 第三级台阶（最高级）- 与门宽度对齐
    
    // 墙角重合点（东南角的内侧角点）
    corner_x = plate_length; // 右墙内侧
    corner_y = 0; // 下墙内侧
    
    translate([wall_thickness, wall_thickness, plate_thickness]) {
        // 三个楼梯台阶，东南角重合在同一个墙角点
        
        // 第一级台阶（最低级，最大）- 角点对齐墙角
        translate([corner_x - steps_total_size, corner_y, 0])
            cube([steps_total_size, step_width_1, step_height * 1]);
        
        // 第二级台阶（中间级）- 角点与第一级相同，但尺寸更小
        translate([corner_x - steps_total_size * 0.75, corner_y, 0])
            cube([steps_total_size * 0.75, step_width_2, step_height * 2]);
        
        // 第三级台阶（最高级，最小）- 角点与前两级相同，宽度与门对齐
        translate([corner_x - steps_total_size * 0.5, corner_y, 0])
            cube([steps_total_size * 0.5, step_width_3, step_height * 3]);
    }
}

module wall_inner() {
    // 新增：左侧装饰墙（带木纹线条）
    difference() {
        translate([0, 0, 0]) {
            cube([plate_length, 100, total_height - 0]);
        }

        // 垂直线条切割（从底部到顶部）
        // 水平刻线（每隔80mm高度）
        for(z = [plate_thickness : groove_spacing : total_height]) {
            translate([-0.1, 100 - 20, z]) { // 从顶部向内部雕刻20mm
                cube([plate_length + 0.2, 35, 2]); // 刻线宽度2mm，贯穿整个墙体长度
            }
        }

        // 新增：窗户挖空
        translate([pool_length, -0.1, plate_thickness + 1000])
            cube([600, 100.2, 800]);
    }
}


module tile_grooves() {
    // 横向缝隙（沿Y轴方向）
    for (x = [tile_size : tile_size : plate_length - 1]) {
        if (x < pool_x_start - mat_thickness || x >= pool_x_end + mat_thickness) {
            // 完整缝隙
            translate([x - groove_width/2, 0, plate_thickness - groove_depth])
                cube([groove_width, plate_width, groove_depth + 0.1]);
        } else {
            // 分割缝隙（跳过泳池区）
            // 南侧部分：从Y=0到pool_y_start - mat_thickness
            translate([x - groove_width/2, 0, plate_thickness - groove_depth])
                cube([groove_width, pool_y_start - mat_thickness, groove_depth + 0.1]);
            // 北侧部分：从Y=pool_y_end + mat_thickness到plate_width
            translate([x - groove_width/2, pool_y_end + mat_thickness, plate_thickness - groove_depth])
                cube([groove_width, plate_width - (pool_y_end + mat_thickness), groove_depth + 0.1]);
        }
    }

    // 纵向缝隙（沿X轴方向）
    for (y = [tile_size : tile_size : plate_width - 1]) {
        if (y < pool_y_start - mat_thickness || y >= pool_y_end + mat_thickness) {
            // 完整缝隙
            translate([0, y - groove_width/2, plate_thickness - groove_depth])
                cube([plate_length, groove_width, groove_depth + 0.1]);
        } else {
            // 分割缝隙（跳过泳池区）
            // 西侧部分：从X=0到pool_x_start - mat_thickness
            translate([0, y - groove_width/2, plate_thickness - groove_depth])
                cube([pool_x_start - mat_thickness, groove_width, groove_depth + 0.1]);
            // 东侧部分：从X=pool_x_end + mat_thickness到plate_length
            translate([pool_x_end + mat_thickness, y - groove_width/2, plate_thickness - groove_depth])
                cube([plate_length - (pool_x_end + mat_thickness), groove_width, groove_depth + 0.1]);
        }
    }
}


module stub_wall() {
    // 1400 为带门墙体的长度
    // 所以该墙长度为 总宽度+墙体宽度-那个墙的长度
    difference() {
    translate([plate_length, 1400, 0]) {
        cube([wall_thickness, plate_width + wall_thickness - 1400, plate_thickness + stub_wall_height]);
    }

    for(z = [0 : groove_spacing : total_height - plate_thickness]) {
        translate([
            plate_length , // 从外表面向内雕刻
            1400, // 确保覆盖整个宽度
            plate_thickness + z - groove_width_wall/2 // 垂直居中刻线
        ]) {
                cube([
                    35, // 刻线深度（带容差）
                    1400, // 覆盖整个墙面宽度
                    groove_width_wall // 刻线高度
                ]);
            }
        }
    }

    // TODO: 这里可能需要一个倒角
}

module outer_wall() {
    translate([0, plate_width + wall_thickness, 0]) {
        cube([plate_length + wall_thickness, wall_thickness * 3, outer_wall_height]);
    }

    // difference() {
    //     translate([0, plate_width + wall_thickness, outer_wall_height]) {
    //         cube([plate_length + wall_thickness, wall_thickness * 3, plate_thickness + stub_wall_height - outer_wall_height]);
    //     }
    // }

    translate([plate_length + wall_thickness, plate_width + wall_thickness * 4, outer_wall_height]) {
        b = wall_thickness * 3;
        rotate([90, 0, -90]) {
            linear_extrude(height = plate_length + wall_thickness) {
                polygon(points = [
                    [0, 0],    // 左下角
                    [b, 0],    // 右下角
                    [b, plate_thickness - outer_wall_height + stub_wall_height],    // 右上角（垂直边）
                    [b / 2, plate_thickness - outer_wall_height + stub_wall_height] // 左上角
                ]);
            }
        }
    }
}

module main() {
    wall_with_door();
    wall_inner();
    floor_with_pool();
    steps();
    stub_wall();
    outer_wall();
}

scale([0.1, 0.1, 0.1]) {
    main();
}
