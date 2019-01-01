pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- mimic
-- by souren and nana

-- DATA

-- SETTINGS
slow_speed = 20 -- the larger the slower the npcs move
tile_slow_speed = 2 -- the larger the slower the tiles animate
player_spr_offset = 32

dying_time = 90 -- number of frames dying npc is shown

splash = true
splash_inst_1 = "take the form of an animal"
splash_inst_2 = "by mimicking its movement"
splash_keys_1 = "move"
splash_keys_2 = "\139\145\148\131"
splash_keys_3 = "start \151"
won_text = "★ you win ★"
stuck_text = "press \151 to restart"

level_size = 16
level_count = 7
start_level = 0

debug_mode = false
debug = "DEBUG\n"

show_trail = true

-- spr numbers
fish_spr = 194
sheep_spr = 196
butter_spr = 210
bird_spr = 212

-- MAP AND TILES
-- tile flag values
tree = 0
water = 1
rock = 2
win = 3
ground = 4
rock_small = 5
cloud = 6
tree_small = 7


-- tile spr values
win_spr = 64
wtr_spr_1 = 144
wtr_spr_2 = 161
wtr_spr_3 = 176
cld_spr_1 = 67
cld_spr_2 = 83
cld_spr_3 = 99
cld_spr_4 = 115

tiles = {tree, water, rock, ground, win, rock_small, cloud, tree_small}
level_tiles = {}
tile_frame_counts = {
    [win_spr] = 1,
    [wtr_spr_1] = 4,
    [wtr_spr_2] = 3,
    [wtr_spr_3] = 4,
    [cld_spr_1] = 4,
    [cld_spr_2] = 4,
    [cld_spr_3] = 4,
    [cld_spr_4] = 4,
}
tile_frame_speeds = {
    [win_spr] = 2,
    [wtr_spr_1] = 60,
    [wtr_spr_2] = 80,
    [wtr_spr_3] = 120,
    [cld_spr_1] = 500,
    [cld_spr_2] = 500,
    [cld_spr_3] = 500,
    [cld_spr_4] = 500,
}

-- ACTORS
npcs = {
    {
        spr_n = fish_spr,
        pattern = {{-1, 0}, {-1, 0}, {-1, 0}, {1, 0}, {1, 0}, {1, 0}},
        move_abilities = {water, win},
        push_abilities = {},
    },
    {
        spr_n = sheep_spr,
        pattern = {{0, -1}, {0, -1}, {1, 0}, {-1, 0}, {0, 1}, {0, 1}},
        move_abilities = {rock, rock_small, win},
        push_abilities = {},
    },
    {
        spr_n = butter_spr,
        pattern = {{0, 1}, {0, 1}, {0, 1}, {0, -1} , {0, -1}, {0, -1}},
        move_abilities = {tree, tree_small, win},
        push_abilities = {},
    },
    {
        spr_n = bird_spr,
        pattern = {{0, -1}, {1, 0}, {0, 1}, {0, -1} , {-1, 0}, {0, 1}},
        move_abilities = {cloud, win},
        push_abilities = {},
    },
}

-- death
dying = {}
dead = {}

-- SFX
player_sfx={}
player_sfx.move={}
player_sfx.move[ground]=1
player_sfx.move[tree]=3
player_sfx.move[tree_small]=3
player_sfx.move[rock]=4
player_sfx.move[rock_small]=4
player_sfx.move[water]=5
player_sfx.move[cloud]=16
player_sfx.transform=2
die_sfx=8
change_pattern_sfx = 10

-- particles
particles = {
    --SCHEMA
    --{
    --    pos = {x, y},
    --    col = c,
    --    draw_fn = foobar(pos, curr_tick, start_tick, end_tick),
    --    start_tick = 0,
    --    end_tick = 0,
    --}
}


-->8
-- particles

function create_trail(a)
    if (not show_trail) return

    local pos = {a.x * 8, a.y * 8}
    local col = get_spr_col(a.spr)
    local pattern_index = get_pattern_index(a)

    local draw_fn
    if a.dx == 1 then
        draw_fn = draw_trail_right
    elseif a.dx == -1 then
        draw_fn = draw_trail_left
    elseif a.dy == 1 then
        draw_fn = draw_trail_down
    elseif a.dy == -1 then
        draw_fn = draw_trail_up
    end

    local frame_len = #a.pattern - 1

    --[[
    -- trail dies before animal steps on it when returning
    if pattern_index > 3 then
        pattern_index -= 3
    end
    frame_len = #a.pattern - 1 - ((pattern_index - 1) * 2)
    --]]

    local end_tick = tick + (slow_speed * frame_len)

    local trail = {
        pos = pos,
        col = col,
        draw_fn = draw_fn,
        start_tick = tick,
        end_tick = end_tick
    }
    add(particles, trail)
end

function draw_trail_up(pos, col, curr_tick, start_tick, end_tick)
    line(pos[1] + 2, pos[2] + 2, pos[1] + 3, pos[2] + 1, col)
    line(pos[1] + 4, pos[2] + 2, col)
    line(pos[1] + 2, pos[2] + 2, col)
end

function draw_trail_down(pos, col, curr_tick, start_tick, end_tick)
    line(pos[1] + 5, pos[2] + 5, pos[1] + 4, pos[2] + 6, col)
    line(pos[1] + 3, pos[2] + 5, col)
    line(pos[1] + 5, pos[2] + 5, col)
end

function draw_trail_right(pos, col, curr_tick, start_tick, end_tick)
    line(pos[1] + 5, pos[2] + 2, pos[1] + 6, pos[2] + 3, col)
    line(pos[1] + 5, pos[2] + 4, col)
    line(pos[1] + 5, pos[2] + 2, col)
end

function draw_trail_left(pos, col, curr_tick, start_tick, end_tick)
    line(pos[1] + 2, pos[2] + 5, pos[1] + 1, pos[2] + 4, col)
    line(pos[1] + 2, pos[2] + 3, col)
    line(pos[1] + 2, pos[2] + 5, col)
end



-->8
-- util

function copy_table(table)
    copy = {}
    for i=1,#table do
      copy[i] = table[i]
    end
    return copy
end

-- e.g. given UP will return LEFT and RIGHT
function get_perp_moves(move)
    if move[1] == 0 then
        return {{-1, 0}, {1, 0}}
    else
        return {{0, -1}, {0, 1}}
    end
end

function pair_equal(a, b)
    if (a[1] == b[1] and a[2] == b[2]) then
        return true
    else
        return false
    end
end

function get_spr_col(spr_n)
    local spr_page = flr(spr_n / 64)
    local spr_row = flr((spr_n % 64) / 16)
    local spr_col = (spr_n % 64) % 16

    local spr_x = spr_col * 8
    local spr_y = (spr_page * 32) + (spr_row * 8)

    return sget(spr_x + 4, spr_y + 4)
end


-->8
-- text

function hcenter(s)
  return 64-#s*2
end

function vcenter(s)
  return 61
end

-->8
-- game logic

function make_actor(x, y, spr_n, pattern, move_abilities, push_abilities)
    local a={}
    a.x = x
    a.y = y
    a.dx = 0
    a.dy = 0
    a.spr = spr_n
    a.move_abilities = copy_table(move_abilities)
    a.push_abilities = copy_table(push_abilities)

    -- pattern
    a.pattern = copy_table(pattern)
    a.t = 0
    a.last_move = {0,0}

    -- animation
    a.frame = 0
    a.frames = 2
    a.flip_x = false

    -- effects
    a.confused = 0

    add(actors, a)
    return a
end

function is_tile(tile_class,x,y)
    if x < 0 or x >= level_size or
       y < 0 or y >= level_size then
        return false
    end

    tile_spr = level_tiles[x][y].spr

    --find out if tile sprite is member of class
    return fget(tile_spr, tile_class)
end

function has_move_ability(a, tile_ability)
    for i=1,#a.move_abilities do
        if a.move_abilities[i] == tile_ability then
            return true
        end
    end
    return false
end

function has_push_ability(a, tile_ability)
    for i=1,#a.push_abilities do
        if a.push_abilities[i] == tile_ability then
            return true
        end
    end
    return false
end

function can_move(x, y, a)
    -- For all tile types, check if this tile is of that type and actor has ability to move
    for t in all(tiles) do
        if(is_tile(t,x,y) and has_move_ability(a,t)) then
            return true
        end
    end
    return false
end

function can_push(x, y, a)
    -- For all tile types, check if this tile is of that type and actor has ability to move
    for t in all(tiles) do
        if(is_tile(t,x,y) and has_push_ability(a,t)) then
            return true
        end
    end
    return false
end

function maybe_push(x, y, dx, dy)
    local new_x = x + dx;
    local new_y = y + dy;
    -- only allow to push onto ground for now
    if (is_tile(ground, new_x, new_y)) then
        level_tiles[new_x][new_y] = level_tiles[x][y]
        level_tiles[x][y] = make_tile(65)
    end
end

function get_pattern_index(a)
    return (a.t % #a.pattern) + 1
end

function get_pattern_move(a)
    return a.pattern[get_pattern_index(a)]
end

function npc_get_move(a)
    local new_move, alt_move

    -- Move according to pattern if possible
    local pattern_move = get_pattern_move(a)
    new_loc = {
        a.x + pattern_move[1],
        a.y + pattern_move[2]
    }
    if can_move(new_loc[1], new_loc[2], a) then
        return pattern_move
    end

    -- Alternative move
    prev_loc = {
        a.x - a.last_move[1],
        a.y - a.last_move[2],
    }

    -- try perpendicular moves first
    local perp_moves = get_perp_moves(pattern_move)
    local could_not_move = false
    local perp_move
    for i=1,#perp_moves do
        perp_move = perp_moves[i]
        alt_loc = {
            a.x + perp_move[1],
            a.y + perp_move[2],
        }

        if can_move(alt_loc[1], alt_loc[2], a) then
            -- dont allow move into prev pos as alt
            if not pair_equal(alt_loc, prev_loc) then
                update_pattern(a, perp_move)
                return perp_move
            end
        end
    end

    -- need to go backwards
    back_move = {-pattern_move[1], -pattern_move[2]}
    back_loc = {
        a.x + back_move[1],
        a.y + back_move[2],
    }
    if can_move(back_loc[1], back_loc[2], a) then
        return {0, 0}
    end


    -- nowhere to move... stuck
    return {0, 0}
end

function npc_die(a)
    a.t = 0
    del(actors, a)
    add(dying, a)
    sfx(die_sfx)
end

function npc_input()
    for a in all(actors) do
        if not is_player(a) then
            -- apply npc pattern
            if a.dx == 0 and a.dy == 0 then
                if tick % slow_speed == 0 then
                    move = npc_get_move(a)
                    if pair_equal(move, {0,0}) then
                        npc_die(a)
                    else
                        a.dx = move[1]
                        a.dy = move[2]
                        a.last_move = move
                        create_trail(a)
                    end
                end
            end
        end
    end
end

function update_npc(a)
    if a.dx != 0 or a.dy != 0 then
        a.t += 1
    end
end

function update_dying(a)
    a.t += 1
    if a.t == dying_time then
        add(dead, a)
    end
end

function update_dead()
    for a in all(dead) do
        del(dying, a)
    end
    dead = {}
end

function update_pattern(a, new_move)
    local update_index = (a.t % #a.pattern) + 1
    a.pattern[update_index] = {new_move[1], new_move[2]}
    -- also mirror the move on the way back to keep the pattern looping
    local mirror_update_index = #a.pattern - update_index
    a.pattern[(mirror_update_index % #a.pattern) + 1] = {-new_move[1], -new_move[2]}

    -- effects
    sfx(change_pattern_sfx)
    a.confused = 1
end

function update_actor(a)
    -- move actor
    if(a.dx != 0 or a.dy != 0) then
        local new_x = a.x + a.dx
        local new_y = a.y + a.dy

        -- push
        if is_player(a) then
            if can_push(new_x, new_y, a) then
                maybe_push(new_x, new_y, a.dx, a.dy)
            end
        end

        if (a.confused == 2) a.confused = 0
        if (a.confused == 1) a.confused += 1

        -- move
        if can_move(new_x, new_y, a) then
            a.x = new_x
            a.y = new_y

            if is_player(a) then
                update_player(a)
                play_player_sfx("move")
            else
                update_npc(a)
            end
        else
            if is_player(a) then
                sfx(0)
            end
        end

        -- actor animation
        a.frame += 1
        a.frame %= a.frames
        a.flip_x = a.dx > 0

        a.dx = 0
        a.dy = 0

        -- effects
    end
end

function update_actors()
    foreach(actors, update_actor)
end

function update_particles()
    remove = {}
    for p in all(particles) do
        if (p.end_tick < tick) then
            add(remove, p)
        end
    end

    for p in all(remove) do
        del(particles, p)
    end
end

function update_dyings()
    foreach(dying, update_dying)
end

function init_actors(l)
    for n in all(npcs) do
        local n_pos = find_sprite(l, n.spr_n)
        if n_pos != nil then
            make_actor(n_pos[1], n_pos[2], n.spr_n, n.pattern, n.move_abilities, n.push_abilities)
        end
    end
end

function is_stuck()
    if not can_move(pl.x+1, pl.y, pl) and
       not can_move(pl.x-1, pl.y, pl) and
       not can_move(pl.x, pl.y+1, pl) and
       not can_move(pl.x, pl.y-1, pl) then
        return true
    else
        return false
    end
end

function no_npc()
    return #actors == 1
end

-->8
-- player

player_spr = 192
player_pattern = {}
player_pattern_i = 0
player_pattern_size = 10 -- must be 1 longer than the max npc pattern length
player_move_abilities = {ground, win}
player_push_abilities = {rock_small, tree_small}

function init_player(l)
    local player_pos = find_sprite(l, player_spr)
    pl = make_actor(
        player_pos[1], player_pos[2], player_spr, {}, player_move_abilities, player_push_abilities)
    reset_player_pattern()
end

function debug_stuff()
--    p = {
--        pos = {8, 8},
--        draw_fn = draw_spark,
--        curr_tick = tick,
--        start_tick = tick,
--        end_tick = 100,
--    }
--    add(particles, p)
end

function player_input()
    if (btnp(0)) pl.dx = -1
    if (btnp(1)) pl.dx = 1
    if (btnp(2)) pl.dy = -1
    if (btnp(3)) pl.dy = 1
    if (btnp(4)) show_trail = not show_trail
    if (btnp(5)) then
        if splash then
            splash = not splash
        else
            change_level = level
        end
    end
end

function reset_player_pattern()
    player_pattern={}
    for i=1,player_pattern_size do
        add(player_pattern, {0,0})
    end
end

function play_player_sfx(action)
    if(action == "move") then
        sfx(player_sfx[action][pl.move_abilities[1]])
        return
    end
    sfx(player_sfx[action])
end


function is_player(a)
    return (#a.pattern == 0)
end

function update_player(p)
    -- check player victory
    if is_tile(win, p.x, p.y) then
        change_level = level + 1
        sfx(11)
        return
    end

    -- save player pattern
    player_pattern_i += 1
    if player_pattern_i > player_pattern_size then
        player_pattern_i = 1
    end
    player_pattern[player_pattern_i][1] = p.dx;
    player_pattern[player_pattern_i][2] = p.dy;
end

-->8
-- game mechanic

function table_concat(t1, t2)
    local tc = {}
    for i=1,#t1 do
        tc[i] = t1[i]
    end
    for i=1,#t2 do
        tc[#t1+i] = t2[i]
    end
    return tc
end

function rev_pattern(pattern)
    reverse = {}
    for i = 1,#pattern do
        reverse[i] = {}
        reverse[i][1] = pattern[#pattern-i+1][1]
        reverse[i][2] = pattern[#pattern-i+1][2]
    end
    return reverse
end

function shift_pattern_halfway(pattern)
    shifted = {}
    local half_len = #pattern / 2.0 - 1
    for i = 1,#pattern do
        shifted[i] = {}
        shifted[i][1] = pattern[((i + half_len) % #pattern) + 1][1]
        shifted[i][2] = pattern[((i + half_len) % #pattern) + 1][2]
    end
    return shifted
end

-- given a pattern returns the concat of the pattern and its inverted reverse
function get_full_pattern(pattern)
    local back_pattern = rev_pattern(pattern)
    for i=1,#back_pattern do
        back_pattern[i][1] = back_pattern[i][1] * -1
        back_pattern[i][2] = back_pattern[i][2] * -1
    end
    return table_concat(pattern, back_pattern)
end

-- give player ability of animal it mimics
function mimic()
    for a in all(actors) do
        if not is_player(a) then
            -- check regular pattern and shifted pattern for backwards mimic
            if contains_pattern(player_pattern, a.pattern) or
                contains_pattern(player_pattern, shift_pattern_halfway(a.pattern)) then
                if(not (pl.move_abilities[1] == a.move_abilities[1])) then
                    play_player_sfx("transform")
                end
                pl.move_abilities = a.move_abilities
                pl.push_abilities = a.push_abilities
                pl.spr = a.spr + player_spr_offset
                reset_player_pattern()
            end
        end
    end
end

function patterns_match(pattern_a, pattern_b, start_a)
    local a_len = #pattern_a
    local b_len = #pattern_b
    for i=1, b_len do
        local a_i = ((start_a + i - 1) % a_len) + 1
        local b_i = i
        if pattern_a[a_i][1] != pattern_b[b_i][1] or
           pattern_a[a_i][2] != pattern_b[b_i][2] then
            return false
        end
    end
    return true
end

function contains_pattern(in_pattern, fit_pattern)
    local in_len = #in_pattern
    local fit_len = #fit_pattern
    -- start matching pattern from fit pattern length back from current player pattern index (wrapped)
    local start_i = ((player_pattern_i - fit_len + player_pattern_size - 1) % player_pattern_size) + 1
    if patterns_match(in_pattern, fit_pattern, start_i) then
        return true
    else
        return false
    end
end

-->8
-- level and map

function make_tile(tile_spr)
    local tile = {}

    local tile_frame_count = tile_frame_counts[tile_spr]
    if (tile_frame_count == nil) tile_frame_count = 0
    tile.frames = tile_frame_count

    local tile_frame_speed = tile_frame_speeds[tile_spr]
    if (tile_frame_speed == nil) tile_frame_speed = 0
    tile.speed = tile_frame_speed
    tile.tick_offset = flr(rnd(tile.speed))

    tile.spr = tile_spr
    tile.frame = flr(rnd(tile_frame_count))
    return tile
end

function init_level(l)
    tick = 0
    actors = {}
    dying = {}
    dead = {}
    particles={}
    level = l
    init_tiles(l)
    init_actors(l)
    init_player(l)
    debug_stuff()
end

-- Loads in level by populating 2d array of tiles `level_tiles`
function init_tiles(l)
    for i=0,level_size do
        if level_tiles[i] == nil then
            level_tiles[i] = {}
        end
        for j=0,level_size do
            level_tiles[i][j] = make_tile(get_tile(i, j, l))
        end
    end
end

-- Given a level number will return the (x,y) position of the sprite
function find_sprite(l, spr_n)
    for i=0,level_size do
        for j=0,level_size do
             if get_sprite(i,j,l) == spr_n then
                return {i, j}
            end
        end
    end
    return nil
end

function get_tile(x,y,l)
    i = (x + 2*l*level_size) % 128
    j = y + flr(level_size * 2*l / 128)*level_size
    return mget(i,j)
end

function get_sprite(x,y,l)
    i = (x + (2*l+1)*level_size) % 128
    j = y + flr(level_size * 2*l / 128)*level_size
    return mget(i,j)
end

-->8
-- draw

function draw_splash()
    cls()

    print(splash_keys_3, hcenter(splash_keys_3)-2, 105, 8)

    if(tick % 60 > 0 and tick % 60 < 20) cls()


    map(100,58,36,10,8,4)

    print(splash_inst_1, hcenter(splash_inst_1), 54, 13)
    print(splash_inst_2, hcenter(splash_inst_2), 64, 13)

    print(splash_keys_1, hcenter(splash_keys_1), 78, 13)
    print(splash_keys_2, 48, 88, 13)
end

function draw_won()
    cls()
    print(won_text, 38, vcenter(won_text)-30, 9)
    print(won_text, 38, vcenter(won_text)-20, 10)
    print(won_text, 38, vcenter(won_text)-10, 11)
    print(won_text, 38, vcenter(won_text), 12)
    print(won_text, 38, vcenter(won_text)+10, 13)
    print(won_text, 38, vcenter(won_text)+20, 14)
end

function draw_level_splash(l)
    local level_text="level "..l
    draw_actor(pl)
    print(level_text, hcenter(level_text), vcenter(level_text), 1)
end

function draw_level()
    local t
    for i=0,level_size do
        for j=0,level_size do
            t = level_tiles[i][j]
            if t.frames != 0 and (tick + t.tick_offset) % t.speed == 0 then
                t.frame += 1
                t.frame %= t.frames
            end
            spr(t.spr + t.frame, i*8, j*8)
        end
    end
end

function draw_actor(a)
    spr(a.spr + a.frame, a.x*8, a.y*8, 1, 1, a.flip_x)
    if (a.confused > 0) print("!", a.x*8 + 3, a.y*8 + 1, 8)
end

function draw_dying(a)
    spr(a.spr, a.x*8, a.y*8, 1, 1, a.flip_x)
    print("?", a.x*8 + 1, a.y*8 + 1, 8)
    print("!", a.x*8 + 4, a.y*8 + 1, 8)
end

function draw_particle(p)
    p.draw_fn(p.pos, p.col, p.curr_tick, p.start_tick, p,end_tick)
end

function draw_actors()
    foreach(actors, draw_actor)
    foreach(dying, draw_dying)
end

function draw_particles()
    foreach(particles, draw_particle)
end

function draw_ui()
    if is_stuck() or no_npc() then
        print(stuck_text, hcenter(stuck_text), vcenter(stuck_text), 7)
    end
end

-->8
-- debug

function draw_debug()
    print(debug, 0, 0, 11)
end

function debug_log(s)
    if(s == null) s = "nil"
    debug..=s.."\n"
end

function debug_table(xs)
    for i = 1,#xs do
        debug ..= pair_str(xs[i]).."\n"
    end
end

function pair_str(p)
    return p[1].."_"..p[2]
end


-->8
-- game loop

function _init()
    init_level(start_level)
    change_level = -1
end

function _update()
    tick += 1
    if change_level == level_count then
        return
    end
    if change_level >= 0 then
        init_level(change_level)
        change_level = -1
        return
    end
    player_input()
    if splash then
        return
    end
    npc_input()
    update_actors()
    update_particles()
    -- update_dyings()
    -- update_dead()
    mimic()
end

function _draw()
    if splash then
        draw_splash()
    elseif change_level == level_count then
        draw_won()
    else
        cls()
        if tick < 50 then
            draw_level_splash(level)
        else
            draw_level()
            draw_particles()
            draw_actors()
            draw_ui()
            if (debug_mode) draw_debug()
        end
    end
end

__gfx__
00000000000000000000000000000000000000000000b00b00b0000b000000000000000000000000000000000000000000000000000000000000000000000000
00000000080800000000000000888800000000000000333000033330000000040000004000033000000000000000000000055000056005000000000000000000
007007008888800000000000088888800088880000033933003393330f0f0004f0f00040000b3000000555000000000000056000055056000099909000999090
00077000888880000000000008f8f880088888800bb33393bb3339330444444444444440003333000055650000000000000555000055555009a99990099a9990
0007700008880000000000000888888008f8f8800bb33393bb333933044044444404444000333b00005555500000000000655500005655500999999009999990
007007000080000000000000088888800888888000033933003393330ff04444ff04444003b33330055556500000000005555600065555000099909000999090
00000000000000000000000000888800008888000000333000033330000040040004004003333330056555500000000006555550055555600000000000000000
00000000000000000000000000000000000000000000b00b00b0000b0000f00f0004f04f00044000000000000000000000000000000000000000000000000000
000000000000000000000000000000000119900000000000000000000000000000000000000000000000000000000000000000000000000000dd0000000dd111
00000000000000000000000000000000011990000000000000000000000aaa0000000000000000000000000000b333000b03b0300000000007d77770007d7771
00000000000000000000000000000000000990000000000000ee000000aaaaa000aaaaa0000000000000000003333b3000333300000000007d77777707d77777
0000000000000000000000000000000000000000e0000ee00e00e00e090aaa00090aaa000000000000000000033b3330000b3000000000007777777707777777
00000000000000000000000000000000011000000e00e00ee0000ee0009999900099999000000000000000000b3333b0b0333303000000000077777700077777
000000000000000000000000000000000119900000ee000000000000090aaa00090aaa0000000000000000000333b33003b3333b0000000000d000d1000d00d0
0000000000000000000000000000000000099000000000000000000000aaaaa000aaaaa00000000000000000003333000033b3000000000000dd00dd000d00d0
00000000000000000000000000000000000000000000000000000000000aaa000000000000000000000000000004400000000000000000000000000000000000
00000000000000000000000000000000000000000000b00b00b0000b000000000000000000000000000000000000000000000000000000000000000000000000
01110000011100001111111011111000011000000000888000088880000000040000004000000000000000000000909008880ccc000000000000000000000000
01111000111100001111111011111000011000000008898800889888080800048080004000000000000000000000040008980c2c000000000088808000888080
01199901119990001199999000999990011990000bb88898bb8889880444444444444440000000000000000009090409088eeccc0000000008a88880088a8880
01199991199990001199999000999990011990000bb88898bb8889880440444444044440000000000000000000400440aaaefe00000000000888888008888880
011999999999900011990000000119900119900000088988008898880880444488044440000000000000000000400400a9aeee00000000000088808000888080
011990999919900011990000000119900119900000008880000888800000400400040040000000000000000000044400aaa00000000000000000000000000000
01199009911990001199000000011990011990000000b00b00b0000b000080080004804800000000000000000000400000000000000000000000000000000000
01199000011990001199000000011990011990000000000000000000000000000000000000000000000000000000000000000000000000000088000000088000
01199000011990001199000000011990011990000000000000000000000888000000000000000000000000000000000000000000000000000787777000787770
01199000011990001199000000011990011990000000000000880000008888800088888000000000000000000000000000000000000000007877777707877777
01199000011990001199111011111990011990008000088008008008090888000908880000000000000000000000000000000000000000007777777707777777
01199000011990001199111011111990011990000800800880000880009999900099999000000000000000000000000000000000000000000077777700077777
01199000011990000099999000999990011990000088000000000000090888000908880000000000000000000000000000000000000000000080008000080080
00099000000990000099999000999990000990000000000000000000008888800088888000000000000000000000000000000000000000000088008800080080
00000000000000000000000000000000000000000000000000000000000888000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccccc0000000000cccccc00000000000000000
0000a00000000000000000000000000000000000000000000000000000cccccccccccccccccccc00cccccc000cccccc0cccccc00cccccccc0000000000000000
000aaa000000000000000000000000000000000000000000000000000cccccccccccccccccccccc0ccccccc00cccccc0ccccccc0cccccccc0000000000000000
00aaaaa00000000000000000000077000007700000077000000077000cccccccccccccccccccccc0ccccccc00cccccc0ccccccc0cccccccc0000000000000000
000aaa000000000000000000007777700777770007777700007777700cccccccccccccccccccccc0ccccccc00cccccc0ccc77cc0cccccccc0000000000000000
0000a0000000000000000000000000000000000000000000000000000cccccccccccccccccccccc0ccccccc00cccccc0cc7cc7c0cccccccc0000000000000000
000000000000000000000000000000000000000000000000000000000cccccccccccccccccccccc0cccccc0000cccc00ccccccc0cccccccc0000000000000000
000000000000000000000000000000000000000000000000000000000cccccc0000000000cccccc000000000000000000cccccc0000000000000000000000000
000000000000000000000000000000000000000000000000000000000cccccc00cccccc00cccccc0000000000000000000000000000000000000000000000000
000550000000000000000000077000007700000077000000077000000cccccc0ccccccc00ccccccc00cccc000000000000000000000000000000000000000000
005555000005550000000000000000000007700000077000000000000cccccc0ccccccc00ccccccc0cccccc00000000000000000000000000000000000000000
055555500055550000000000000770000077770000777700000770000cccccc0ccccccc00ccccccc0cccccc00000000000000000000000000000000000000000
055555500055555000055000007777000077777000777770007777000cccccc0ccccccc00ccccccc0cccccc00000000000000000000000000000000000000000
055555500555555000555500007777700777777007777770007777700cccccc0ccccccc00ccccccc0cccccc00000000000000000000000000000000000000000
005555000555555000555550077777700000000000000000077777700cccccc0ccccccc00ccccccc0cccccc00000000000000b00000000000000000000000000
000000000000000000000000000000000000000000000000000000000cccccc00cccccc00cccccc00cccccc00000000000000000000000000000000000000000
000330000000000000000000000000000000000000000000000000000cccccc00cccccc00cccccc00cccccc0cccccccc0cccccc00cccccc00000000000000000
003333000003300000000000000000000000000000000000000000000cccccccccccccccccccccc00cccccccccccccccccccccc0ccccccc00000000000000000
003333000003300000000000007770000007770000077700007770000cccccccccccccccccccccc00cccccccccccccccccccccc0ccccccc00000000000000000
033333300033330000033000077777700077777000777770077777700cccccccccccccccccccccc00ccc77ccccccccccccccccc0cc77ccc00000000000000000
033333300033330000333300000000000000000000000000000000000cccccccccccccccccccccc00cc7cc7cccccccccccccccc0c7cc7cc00000000000000000
003333000333333000333300000770000077000000770000000770000cccccccccccccccccccccc00cccccccccccccccccccccc0ccccccc00000000000000000
0004400000044000000440000077770007777000077770000077770000ccccccccccccccccccccc000cccccccccccccccccccc00cccccc000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000cccccc000000000cccccccc00000000000000000000000000000000
11111111000000000000000000000700000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000
1ae89ea1000000000000000000007770000007000000070000007770000000000000000000000000000000000000000000000000000000000000000000000000
1ebddbe1000000000000000000000000000077700000777000000000000000000000000000000000000000000000000000000000000000000000000000000000
19dccd81000000000000000000770000077000000770000000770000000000000000000000000000000000000000000000000000000000000000000000000000
18dccd91000000000000000007777000777700007777000007777000000000000000000000000000000000000000000000000000000000000000000000000000
1ebddbe1000000000000000007777770777777007777770007777770000000000000000000000000000000000000000000000000000000000000000000000000
1ae98ea1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000a0000000a0000000a00000007000000070000000a0000000a0000000a000
06060606060626060606060675060606000000000000000000000000000000000606060606060606060606067506062600000000000000000000000000000000
000aa900000aa900000aa9000007a90000077900000a7700000aa700000aa900000aa900000aa900000a0600000aa900000aa900000aa900000aa900000aa900
00aaa99000aaa99000aaa990007aa9900077a99000a7799000aa779000aaa77000aaa97000aaa99000aaa99000aaa99000aaa99000aaa99000aaa99000aaa990
00099900000999000009990000099900000999000007990000077900000977000009970000099900000999000009990000099900000999000009990000099900
00009000000090000000900000009000000090000000900000009000000070000000700000009000000090000000900000009000000090000000900000009000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00cccccc00cccccc00cccccc00cccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0ccccccc0ccccccc0ccccccc0ccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0ccc77cc0ccc77cc0ccc77cc0cc77ccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0cc7cc7c0cc7cc7c0cc7cc7c0c7cc7cc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0ccccccc0ccccccc0ccccccc0ccccccc000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000
0ccccccc0ccccccc0ccccccc0ccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0cccccc00cccccc00cccccc00cccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000cccccc00cccccc00cccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc0cccccc00cccccc00cccccc0007000000000000000000000000071000000000000000000000000000000000000000000000000000000000000000000
ccccc77c0cc77cc00cc77cc00cccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccc7cc70c7cc7c00c7cc7c00cc77cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c77ccccc0cccccc00cccccc00c7cc7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7cc7cccc0cccccc00cccccc00cccccc0000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc0cccccc00cccccc00cccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000cccccc00cccccc00cccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccc77ccccccc77ccccc77ccccc77cccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cc7cc7ccccc7cc7ccc7cc7ccc7cc7ccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000066000000066000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888800000000000000000000000000066000000066000000000000000000000707070707070707070707070707070707070707070707070707070707070707
0888888000888800009990900099090006666666006666660000000000bb00000000000000000000000000000000000000000000000000000000000000000000
08f8f8800888888009999900099990000666666000666660b0000bb00b00b00b0714141414141414141414141414140707141414141414141414141414141407
0888888008f8f880099999000999900006666660006666600b00b00bb0000bb00000000000000000000000000000000000000000000000000000000000000000
08888880088888800099909000990900060000600060006000bb000000000000070505141414b6b6b6b6140606060607070505050514b6b6b6b6140606060607
00888800008888000000000000000000060000600066006600000000000000000000000000000000000000000000000000000000000000000000000000044000
0000000000000000000000000000000000000000000000000000000000000000070505141414b6b6b6b6140606060607070505050514b6b6b6b6140606060607
00000000000000000e0000e000e00e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000eee00eee0eeeeee000000000c000000c000000000000000007050525251405b6b6b614060606060707050505051405b6b62c1406062d0607
0000000000000000eee00eee0eeeeee0000cc000cc0cc0cc00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000eeeeee000eeee0000cccc000cccccc00000000000000000070505141414b6b6b6b6140606060607074c05050514b6b6b6b6140505060507
000000000000000000eeee00000ee0000cccccc000cccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000eeeeee000eeee00cc0cc0cc000cc00000000000000000000714b0b01414141425141406050605070714b0b0141414142514140505050507
0000000000000000eee00eee0eeeeee0c000000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000e0000e000e00e00000000000000000000000000000000000714b0b01414141414141406060506070714b0b0141414141414140505050507
00000000000000000000000000000000088000000088000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000088000000088000000000000000000000714b0b01414141414141414141414070714b0b0141414141414141414141407
00000000000000000088808000880800088888880088888800000000008800000000000000000000000000000000000000000000000000000000000000000000
00000000000000000888880008888000088888800088888080000880080080080714b0000000000000000000001414070714b000000000000000000000141407
00000000000000000888880008888000088888800088888008008008800008800000000000000000000000000000000000000000000000000000000000000000
00000000000000000088808000880800080000800080008000880000000000000714b0000212420212422200001414070714b000021242021242224200141407
00000000000000000000000000000000080000800088008800000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000714b0000313430313432300001414070714b000031343031343234100141407
00000000000000000800008000800800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000008880088808888880000880008000000800000000000000000714b0000000000000000000001414070714b000000000000000000000141407
00000000000000008880088808888880008888008808808800000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000888888000888800088888800888888000000000000000000714b0002d002c004c004d00141414070714b0b0b0b0b0b0b0b0b0b014141407
00000000000000000088880000088000888008880088880000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000888888000888800800000080000000000000000000000000714b0b0b0b0b0b0b0b0b000b0141407070cb0b0b0b0b0b0b0b0b0b0b0141407
00000000000000008880088808888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000800008000800800000000000000000000000000000000000707070707070707070707070707070707070707070707070707070707070707
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000011100000111000001100000011100000111000001100000111111100110000000000000000000000000000000000000
00000000000000000000000000000000011110001111000001100000011110001111000001100000111111100110000000000000000000000000000000000000
00000000000000000000000000000000011999011199900001199000011999011199900001199000119999900119900000000000000000000000000000000000
00000000000000000000000000000000011999911999900001199000011999911999900001199000119999900119900000000000000000000000000000000000
00000000000000000000000000000000011999999999900001199000011999999999900001199000119900000119900000000000000000000000000000000000
00000000000000000000000000000000011990999919900001199000011990999919900001199000119900000119900000000000000000000000000000000000
00000000000000000000000000000000011990099119900001199000011990099119900001199000119900000119900000000000000000000000000000000000
00000000000000000000000000000000011990000119900001199000011990000119900001199000119900000119900000000000000000000000000000000000
00000000000000000000000000000000011990000119900001199000011990000119900001199000119900000119900000000000000000000000000000000000
00000000000000000000000000000000011990000119900001199000011990000119900001199000119900000009900000000000000000000000000000000000
00000000000000000000000000000000011990000119900001199000011990000119900001199000119911100000000000000000000000000000000000000000
00000000000000000000000000000000011990000119900001199000011990000119900001199000119911100110000000000000000000000000000000000000
00000000000000000000000000000000011990000119900001199000011990000119900001199000009999900119900000000000000000000000000000000000
00000000000000000000000000000000000990000009900000099000000990000009900000099000009999900009900000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000003330333033303330033000003330330033303330333030000000333003303030333033303330330033300000000000000000000000
00000000000000000000003330030033300300300000003030303003003330303030000000333030303030300033303000303003000000000000000000000000
00000000000000000000003030030030300300300000003330303003003030333030000000303030303030330030303300303003000000000000000000000000
00000000000000000000003030030030300300300000003030303003003030303030000000303030303330300030303000303003000000000000000000000000
00000000000000000000003030333030303330033000003030303033303030303033300000303033000300333030303330303003000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000003330333033303330333033303300000033300330000033303330303033300000333033300330000033300330333033300000000000000000
00000000000000003030303003000300300030303030000003003030000003003030303030000000030003003000000030003030303033300000000000000000
00000000000000003330333003000300330033003030000003003030000003003330330033000000030003003330000033003030330030300000000000000000
00000000000000003000303003000300300030303030000003003030000003003030303030000000030003000030000030003030303030300000000000000000
00000000000000003000303003000300333030303030000003003300000003003030303033300000333003003300000030003300303030300000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000888008808080888000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000888080808080800000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000808080808080880000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000808080808880800000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000808088000800888000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000008888800088888000888880008888800000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000088800880880088808880888088000880000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000088000880880008808800088088000880000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000088800880880088808800088088808880000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000008888800088888000888880008888800000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000008880888088008080000000000000000000000000888088800880888088800000000000000000000000000000000000
00000000000000000000000000000000008880800080808080000000000000000000000000808080008000800008000000000000000000000000000000000000
00000000000000000000000000000000008080880080808080000000000000000000000000880088008880880008000000000000000000000000000000000000
00000000000000000000000000000000008080800080808080000000000000000000000000808080000080800008000000000000000000000000000000000000
00000000000000000000000000000000008080888080800880000000000000000000000000808088808800888008000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000088888000000000000000000000000000000000000088888000000000000000000000000000000000000000000
00000000000000000000000000000000000000880008800000000000000000000000000000000000880808800000000000000000000000000000000000000000
00000000000000000000000000000000000000880808800000000000000000000000000000000000888088800000000000000000000000000000000000000000
00000000000000000000000000000000000000880008800000000000000000000000000000000000880808800000000000000000000000000000000000000000
00000000000000000000000000000000000000088888000000000000000000000000000000000000088888000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0000080000000000000104100404000000000000000000000002000101000000000000000000000000020201000000000000000000000000000202000000000008100040404040020202020202020008040420404040400202020200000000080101804040404002020202020202000880000040404040400000000000000008
0808080808080808080808080808080802020202020000000800000000000000020202020000000000000000000000000202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
60606060606060606160606060606060000000000000000000000000000000000b0b0b0b61610b0b0b0b0b0b0b0b0b0b0000000000000000000000000000000060616162606060606060606060616060000000000000000000000000000000005760616161616060606061616060606100000000000000000000000000000000
60616061606260616160616260606062000000000000000000000000000000000b0b0b616261610b0b0b0b0b0b0b0b0b000000000000000000000000000000006060616060606060606162606260606000000000000000000000000000000000a1600b0b0b0b0b400b0b0b0b0b60616100000000000000000000000000000000
60606060616060616060626060606060000000000000000000000000000000000b0b604748a049610b0b0b0b0b0b0b0b00000000000000000000000000000000484c60626061606162606060606060600000000000000000000000000000000057610b0b0b0b0b0b0b0b0b0b0b0b616100000000000000000000000000000000
60606062606060606060606061606160000000000000000000000000000000000b606257400b6749600b0b0b0b0b0b0b0000000000000000000000000000000051576060604060606060606051606060000000000000000000000000000000005760414141414141414141414141416000000000000000004100000000000000
61606060616060606161626060606160000000000000000000000000000000000b0b60570b0b0b674c610b0b0b0b0b0b000000000000000000000000000000005167a048484c60614748496060516060000000000000000000000000000000006a484848a0484848b0484848a048b048000000000000000000c2000000000000
60606060606060616060606060606060000000000000000000000000000000000b0b616a490b0b0b57600b0b0b0b0b0b000000000000000000000000000000005051515151674848580ba151515160600000000000000000c2000000000000005051515160606060515151515051505000000000000000000000000000000000
600b0b0b0b0b0b0b0b0b0b0b6060406000c000000000000000000000000000000b0b0b6167490b0b57600b6060600b0b0000000000000000000000000000000050515151515151516a486c5151606060000000000000000000000000000000005150516060616060515051515160606100000000000000000000000000000000
60606060600b60606060606060616060000000000000000000000000000000000b0b0b0b6067a0485860606260606060000000000000000000000000000000005051505151505051515151515161606000c4000000000000000000000000d2005150606041515151515151516060606000000000c00000000000000000000000
61606061600b0b606160616060606060000000000000000000000000000000000b0b0b0b6060606067496160606260600000000000000000000000000000000051515150515151515150904a51606060000000000000000000000000000000005161604141605151505151505160606100000000000000000000000000000000
6060626061600b0b0b60606062606060000000000000000000000000000000000b0b0b0b616060616067484848b0496100000000000000000000000000c200000b0b0b0b0b51515051515751506060600000c0000000000000000000000000006061414141616060615150515150506000000000000000000000c40000000000
62606060606060600b0b6060606160600000000000000000000000d2000000000b0b0b0b0b0b0b0b6060616160606a480000000000000000000000000000000051510b0b0b52415147a06c516061606100000000000000000000000000000000600b0b0b41520b61605160605151506000000000000000000000000000000000
6060606060606260620b606060606260000000000000000000000000000000000b0b0b0b0b0b0b0b0b0b0b60606061600000000000000000000000000000d20050519048a04848b06c5151515150606000000000000000000000000000000000610b606060604141606060616060616100000000000000000000000000000000
48a0484960606060600b606062606060000000000000000000000000000000000b0b0b0b0b0b0b0b0b0b0b6060606060000000000000000000000000000000006050576050505051515151505051606000000000000000000000000000000000610b60616060606160605160606050600000000000d200000000000000000000
6060606a48496060600b606060606060000000000000000000000000000000000b0b0b0b0b0b0b0b0b0b0b6162626160000000000000000000000000000000006061576060500b0b515051515160606000000000000000000000000000000000600b606060616161515151515150505000000000000000000000000000000000
60616160616749606060606060606160000000000000000000000000000000000b0b0b0b0b0b0b0b0b0b0b60616160610000c00000000000000000000000000048486d6061605060605151506060606100000000000000000000000000000000600b606060616060605150505150505000000000000000000000000000000000
626062606060a1606060606260606060000000000000000000000000000000000b0b0b0b0b0b0b0b0b0b0b0b0b6061610000000000000000000000000000000060606060606261606160606060606162000000000000000000000000000000006160606160606161616150505050505000000000000000000000000000000000
6160626160606060616060616061606000000000000000000000000000000000414141414141414141414041414141410000000000000000000000000000000061616261616161616161616161616161000000000000000000000000000000006161616161616161616161616161616100000000000000000000000000000000
6061606060606061616261626162606000000000000000000000000000000000414141414141414141436343414141410000000000000000000000000000000061414141414141414141414141414161000000000000000000000000000000416141414141414141414141414141416100000000000000000000000000000041
60626260616161626060616060616060000000000000000000000000000000004141414141414141436444734341414100000000000000000000000000000000610b4141414141414141414141410b6100000000000000000000000000000041610b4141414141414141414141410b6100000000000000000000000000000041
6060616160606060616060515150626100000000000000000000000000000000414141414141414143534363536341410000000000000000000000000000000061414141416060515151415151600b610000000000000000000000000000004161414141416060515151415151600b6100000000000000000000000000000041
606161616062626060616050405060600000000000000000000000000000000041414141414141435363435043534341000000000000000000d40000000000006241414160605151516041520b604161000000000000000000000000000000006141414160605151516041520b60416100000000000000000000000000000000
60606060606060616160605050506060000000000000000000000000000000004141414141414163434350505164644100000000000000000000000000000000614141416060515151606151410b41610000000000000000000000c400000000614141416060515151606151410b41610000000000000000000000c400000000
6062606160606062605150515051515000000000000000000000000000000000414141414141534353505151505366430000000000000000000000000000000061414141605151515161515041515161000000000000000000000000000000006141414160515151516151504151516100000000000000000000000000000000
6062626060606060605041505050615100000000000000000000000000000000414141414141415152515151515041410000000000000000000000000000000061414141605151405161606051515161000000000000000000000000000000006141414160515140516162604151516100000000000000000000000000000000
6061606041414160605141505150605000000000000000000000000000000000414141414141415151515151515141410000000000000000000000000000000061414141606251515061616051516060000000000000000000000000000000006141414160605151506161605151606000000000000000000000000000000000
6160615241414141605041505150605100000000000000000000000000000000616162414141505151525151504141410000000000000000000000000000000061414141626061515051515151516060000000000000000000000000000000006141414141606151505151515151606200000000000000000000000000000000
6060515041414141605041505050605000000000000000000000000000000000b0484960415051515050515050415050000000000000000000c400000000000060414141414141606160606061606161000000000000000000000000000000006041414141414160616060606160626100000000000000000000000000000000
62605050524141414141415060506060000000000000000000000000000000006262576162605051505151505052415000d2000000000000000000000000000062414141414141414141415161616162000000000000000000000000000000006041414141414141414141516161616100000000000000000000000000000000
60605150416041414141415060506062000000000000000000000000000000006160a1615150505250505151514151510000000000000000000000000000000060414141414141415241516061616160000000000000000000000000000000006041414141414141524151606261616000000000000000000000000000000000
62605150506141616161515161515061000000c40000c000000000000000000041604b51505250515150505141415151c000000000000000000000000000000061414141414141415151505161626160000000000000000000000000000000006141414141414141515150516161616000000000000000000000000000000000
60615051506060606060626060606161000000000000000000000000000000004162414141414141414141414141416000000000000000000000000000000000616141414141415051516151474848b00000c000000000000000000000000000616141414141415051516151474848b00000c000000000000000000000000000
60606160616061616161616161616060000000000000000000000000000000006161606161616160616161626160616100000000000000000000000000000000616161626161616161516161a161616000000000000000000000000000000000616161616161616161516161a162616000000000000000000000000000000000
__sfx__
000400000653007500005002640000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000417006060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600001f43026420274102e2102e210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001402015010150200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500001063010600156201060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300000f76013750167400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000011150111501715017150111501115012150121500e1500d1500b150061500215001150001500015000150076500765007650076500010000100001000010000100001000010000100056000560005600
001000002610026130261300e1300e1300e13026130261300e1300e1300e13026130261302d61032610376103d6103f6103c6103d6103c6102f630296301e610176000b600076000560003600026000060000600
000c0000220601e050210501d0501e05027050240502100029100291000000024000006000060000600006000060000600006000060000600006000060000600006000060012600126001260012600126000c600
000700003051030520305103b100001001c7001570016600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000e0000210501c050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00080000000001e02001000000001e030230502705000000010002f050040002f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400003175038740387303872038720387100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011800100c55000500105500050013550005000e55010550155500c5500e550135500e55017550155501355013500005000050000500005000050000500005000050000500005000050000500005000050000500
010c00100c0530c000000000c0000c6532960034600396000c0530c0000c0530c0530c6531b60015600126000c0000f6000f6000f6000c0000f6000d6000c6000a60000600076000460000600006000060000600
010c00202401524025240052b0252b0152700528015280252d0152d025270052b0252b0152700524015240252501525025240052c0252c0152700528015280252701527025270052702527015270052501525025
001000000361005610046100561003610016000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 4d0e0f44

