----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/09/2024 10:20:37 AM
-- Design Name: 
-- Module Name: space_invaders_Graph - rtl
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- btn connected to up/down pushbuttons for now but
-- eventually will get data from UART
entity space_invaders_Graph is
    port(
        clk, reset: in std_logic;
        btn: in std_logic_vector(4 downto 0);
        video_on: in std_logic;
        pixel_x, pixel_y: in std_logic_vector(9 downto 0);
        graph_rgb: out std_logic_vector(2 downto 0);
        hit_cnt: out std_logic_vector(1 downto 0)
    );
end space_invaders_Graph;

architecture si_arch of space_invaders_Graph is
-- Signal used to control speed of ball and how
-- often pushbuttons are checked for paddle movement.
    constant SHIP_SPEED: integer := 3;
    constant SHIP_SIZE: integer := 16;
   
    signal ship_x_l, ship_x_r: unsigned(9 downto 0);
    signal ship_y_t, ship_y_b: unsigned(9 downto 0);
    signal ship_x_reg, ship_x_next: unsigned(9 downto 0);
    signal ship_y_reg, ship_y_next: unsigned(9 downto 0);
    signal bool_l, bool_r, bool_t, bool_b: std_logic;
    signal bool_tlrb: std_logic_vector(3 downto 0);
    
    signal alien1_x_l, alien1_x_r : unsigned(9 downto 0);
    signal alien1_y_t, alien1_y_b : unsigned(9 downto 0);
    signal alien1_x_reg, alien1_x_next : unsigned(9 downto 0);
    signal alien1_y_reg, alien1_y_next : unsigned(9 downto 0);
    signal alien2_x_l, alien2_x_r : unsigned(9 downto 0);
    signal alien2_y_t, alien2_y_b : unsigned(9 downto 0);
    signal alien2_x_reg, alien2_x_next : unsigned(9 downto 0);
    signal alien2_y_reg, alien2_y_next : unsigned(9 downto 0);
    
    signal refr_tick: std_logic;
-- x, y coordinates (0,0 to (639, 479)
    signal pix_x, pix_y: unsigned(9 downto 0);
-- screen dimensions
    constant MAX_X: integer := 640;
    constant MAX_Y: integer := 480;
    type rom_type16 is array(0 to 15) of std_logic_vector(15 downto 0);
    type rom_type8 is array(0 to 7) of std_logic_vector(0 to 7);
    constant SHIP_ROM: rom_type16:= (
        "0000000110000000",
        "0000001111000000",
        "0000011111100000",
        "0000011111100000",
        "0000011111100000",
        "0000011111100000",
        "0000011111100000",
        "0000011111100000",
        "0000011111100000",
        "0000011111100000",
        "0000011111100000",
        "0001111111111000",
        "0111111111111110",
        "1111111111111111",
        "1111111111111111",
        "1100010000100011");
        
    signal romSS_addr, romSS_col: unsigned(3 downto 0);
    signal romSS_data: std_logic_vector(15 downto 0);
    signal romSS_bit: std_logic; 
        
    constant ALIEN1_ROM: rom_type16:= (
        "1111111111111111",
        "1111111111111111",
        "0000011111100000",
        "0000111111110000",
        "0001111111111000",
        "0000001111000000",
        "1111111111111111",
        "1111111111111111",
        "1111111111111111",
        "1111111111111111",
        "1111111111111111",
        "1111100000011111",
        "1111000000001111",
        "1110000000000111",
        "1100000000000011",
        "1000000000000001");
    
    signal romA1_addr, romA1_col: unsigned(3 downto 0);
    signal romA1_data: std_logic_vector(15 downto 0);
    signal romA1_bit: std_logic; 
-- object output signals -- new signal to indicate if
-- scan coord is within ball

    type asteroid_rom_type is array(0 to 7) of std_logic_vector(0 to 7); 
    constant ASTEROID_1_ROM: asteroid_rom_type := ( 
        "00011000", 
        "01100110", 
        "00011000", 
        "01100110", 
        "01100110", 
        "00011000", 
        "01100110", 
        "00011000"); 

    signal asteroid_1_rom_addr, asteroid_1_rom_col: unsigned(2 downto 0); 
    signal asteroid_1_rom_data: std_logic_vector(7 downto 0); 
    signal asteroid_1_rom_bit: std_logic; 
    signal sq_asteroid_1_on, asteroid_1_on: std_logic;
   
    constant ASTEROID_2_ROM: asteroid_rom_type := ( 
        "11000011", 
        "01100110", 
        "00111100", 
        "00011000", 
        "00111100", 
        "01100110", 
        "11000011", 
        "10000001"); 

    signal asteroid_2_rom_addr, asteroid_2_rom_col: unsigned(2 downto 0); 
    signal asteroid_2_rom_data: std_logic_vector(7 downto 0); 
    signal asteroid_2_rom_bit: std_logic;
    signal sq_asteroid_2_on, asteroid_2_on: std_logic; 

    constant ASTEROID_3_ROM: asteroid_rom_type := ( 
        "00110011", 
        "11001100", 
        "00110011", 
        "11001100", 
        "00110011", 
        "11001100", 
        "00110011", 
        "11001100" ); 

    signal asteroid_3_rom_addr, asteroid_3_rom_col: unsigned(2 downto 0); 
    signal asteroid_3_rom_data: std_logic_vector(7 downto 0); 
    signal asteroid_3_rom_bit: std_logic; 
    signal sq_asteroid_3_on, asteroid_3_on: std_logic;
    
    constant ASTEROID_1_SIZE: integer := 8; 
    constant ASTEROID_2_SIZE: integer := 8; 
    constant ASTEROID_3_SIZE: integer := 8;
    
    signal asteroid_1_x_l, asteroid_1_x_r: unsigned(9 downto 0);
    signal asteroid_1_y_t, asteroid_1_y_b: unsigned(9 downto 0); 
    signal asteroid_1_x_reg, asteroid_1_x_next: unsigned(9 downto 0); 
    signal asteroid_1_y_reg, asteroid_1_y_next: unsigned(9 downto 0);  

    signal asteroid_2_x_l, asteroid_2_x_r: unsigned(9 downto 0); 
    signal asteroid_2_y_t, asteroid_2_y_b: unsigned(9 downto 0); 
    signal asteroid_2_x_reg, asteroid_2_x_next: unsigned(9 downto 0); 
    signal asteroid_2_y_reg, asteroid_2_y_next: unsigned(9 downto 0);  

    signal asteroid_3_x_l, asteroid_3_x_r: unsigned(9 downto 0); 
    signal asteroid_3_y_t, asteroid_3_y_b: unsigned(9 downto 0); 
    signal asteroid_3_x_reg, asteroid_3_x_next: unsigned(9 downto 0); 
    signal asteroid_3_y_reg, asteroid_3_y_next: unsigned(9 downto 0);  
    
    signal asteroid_1_x_delta_reg, asteroid_1_x_delta_next: unsigned(9 downto 0); 
    signal asteroid_1_y_delta_reg, asteroid_1_y_delta_next: unsigned(9 downto 0); 
    
    signal asteroid_2_x_delta_reg, asteroid_2_x_delta_next: unsigned(9 downto 0); 
    signal asteroid_2_y_delta_reg, asteroid_2_y_delta_next: unsigned(9 downto 0); 

    signal asteroid_3_x_delta_reg, asteroid_3_x_delta_next: unsigned(9 downto 0); 
    signal asteroid_3_y_delta_reg, asteroid_3_y_delta_next: unsigned(9 downto 0); 
    
    signal asteroid1_rgb, asteroid2_rgb, asteroid3_rgb: std_logic_vector(2 downto 0);
    
--asteroid movements 
    constant ASTEROID_1_V_P: unsigned(9 downto 0) := to_unsigned(2,10); 
    constant ASTEROID_1_V_N: unsigned(9 downto 0) := unsigned(to_signed(-2,10)); 

    constant ASTEROID_2_V_P: unsigned(9 downto 0) := to_unsigned(2,10); 
    constant ASTEROID_2_V_N: unsigned(9 downto 0) := unsigned(to_signed(-2,10)); 

    constant ASTEROID_3_V_P: unsigned(9 downto 0) := to_unsigned(2,10); 
    constant ASTEROID_3_V_N: unsigned(9 downto 0) := unsigned(to_signed(-2,10));  

   type firing_rom_type is array(0 to 7) of std_logic_vector(0 to 7); 
   constant FIRING_BALL_ROM: firing_rom_type:= ( 
           "00011000", 
           "00111100", 
           "01111110", 
           "11111111",
           "11111111", 
           "01111110", 
           "00111100", 
           "00011000"); 

    signal firing_rom_addr, firing_rom_col: unsigned(2 downto 0); 
    signal firing_rom_data: std_logic_vector(7 downto 0); 
    signal firing_rom_bit: std_logic;  
    signal sq_firing_ball_on, firing_ball_on: std_logic;
    signal firing_ball_rgb: std_logic_vector(2 downto 0);
    
    -- FIRING BALL SIZE 
    constant FIRING_BALL_SIZE: integer := 8; 
    -- fire ball coordinates  
    signal firing_ball_x_l, firing_ball_x_r: unsigned(9 downto 0); 
    signal firing_ball_y_t, firing_ball_y_b: unsigned(9 downto 0); 
    signal firing_ball_x_reg, firing_ball_x_next: unsigned(9 downto 0); 
    signal firing_ball_y_reg, firing_ball_y_next: unsigned(9 downto 0); 
    signal firing_ball_x_delta_reg, firing_ball_x_delta_next: unsigned(9 downto 0); 
    signal firing_ball_y_delta_reg, firing_ball_y_delta_next: unsigned(9 downto 0); 
     
    signal x1_delta_reg, x1_delta_next, x2_delta_reg, x2_delta_next: unsigned(9 downto 0);
    signal y1_delta_reg, y1_delta_next, y2_delta_reg, y2_delta_next: unsigned(9 downto 0);
-- ball movement can be pos or neg
    constant AL1_V_P: unsigned(9 downto 0):= to_unsigned(1,10);
    constant AL1_V_N: unsigned(9 downto 0):= unsigned(to_signed(-1,10));
    
    constant AL2_V_P: unsigned(9 downto 0):= to_unsigned(1,10);
    constant AL2_V_N: unsigned(9 downto 0):= unsigned(to_signed(-1,10));
    
    constant ALIEN2_ROM: rom_type16:= (
            "1111111111111111",
            "1111111111111111",
            "0000011111100000",
            "0000111111110000",
            "0001111111111000",
            "0000011111100000",
            "1111111111111111",
            "1111111111111111",
            "1111111111111111",
            "1111111111111111",
            "1111111111111111",
            "1111100000011111",
            "1111000000001111",
            "1110000000000111",
            "1100000000000011",
            "1000000000000001");
            
    signal romA2_addr, romA2_col: unsigned(3 downto 0);
    signal romA2_data: std_logic_vector(15 downto 0);
    signal romA2_bit: std_logic; 
    
    signal sq_spaceship_on, spaceship_on: std_logic;
    signal spaceship_rgb: std_logic_vector(2 downto 0);

    signal sq_alien1_on, alien1_on : std_logic;
    signal alien1_rgb : std_logic_vector(2 downto 0);
    signal sq_alien2_on, alien2_on : std_logic;
    signal alien2_rgb : std_logic_vector(2 downto 0);
    
    signal hit_cnter_reg, hit_cnter_next: unsigned(1 downto 0);
-- ====================================================
    begin
        process (clk, reset)
            begin
                if (reset = '1') then
                    ship_x_reg <= to_unsigned(319, 10);
                    ship_y_reg <= to_unsigned(400, 10);
                    alien1_x_reg <= (others => '0');
                    alien1_y_reg <= (others => '0');
                    x1_delta_reg <= ("0000000001");
                    y1_delta_reg <= ("0000000000");
                    alien2_x_reg <= to_unsigned(20, 10);
                    alien2_y_reg <= to_unsigned(10, 10);
                    x2_delta_reg <= ("0000000001");
                    y2_delta_reg <= ("0000000000");
                    asteroid_1_x_reg <= (others => '0'); 
                    asteroid_1_y_reg <= (others => '0');
                    asteroid_2_x_reg <= (others => '0'); 
                    asteroid_2_y_reg <= (others => '0');
                    asteroid_3_x_reg <= (others => '0'); 
                    asteroid_3_y_reg <= (others => '0');
                    firing_ball_x_reg <= (others => '0'); 
                    firing_ball_y_reg <= (others => '0'); 
                    hit_cnter_reg <= (others => '0');                   
                elsif (clk'event and clk = '1') then
                    ship_x_reg <= ship_x_next;
                    ship_y_reg <= ship_y_next;
                    alien1_x_reg <= alien1_x_next;
                    alien1_y_reg <= alien1_y_next;
                    x1_delta_reg <= x1_delta_next;
                    y1_delta_reg <= x1_delta_next;
                    alien2_x_reg <= alien2_x_next;
                    alien2_y_reg <= alien2_y_next;
                    x2_delta_reg <= x2_delta_next;
                    y2_delta_reg <= y2_delta_next;
                    
                    asteroid_1_x_reg <= asteroid_1_x_next; 
                    asteroid_1_y_reg <= asteroid_1_y_next;
                    asteroid_2_x_reg <= asteroid_2_x_next; 
                    asteroid_2_y_reg <= asteroid_2_y_next;
                    asteroid_3_x_reg <= asteroid_3_x_next; 
                    asteroid_3_y_reg <= asteroid_3_y_next; 

                    asteroid_1_x_delta_reg <= asteroid_1_x_delta_next; 
                    asteroid_1_y_delta_reg <= asteroid_1_x_delta_next; 
                    asteroid_2_x_delta_reg <= asteroid_2_x_delta_next; 
                    asteroid_2_y_delta_reg <= asteroid_2_y_delta_next; 
                    asteroid_3_x_delta_reg <= asteroid_3_x_delta_next; 
                    asteroid_3_y_delta_reg <= asteroid_3_y_delta_next; 
                    
                    firing_ball_x_reg <= firing_ball_x_next; 
                    firing_ball_y_reg <= firing_ball_y_next; 
                    hit_cnter_reg <= hit_cnter_next;
                end if;
        end process;

        -- refr_tick: 1-clock tick asserted at start of v_sync,
        -- e.g., when the screen is refreshed -- speed is 60 Hz
        refr_tick <= '1' when (pix_y = 481) and (pix_x = 0) else '0';
        pix_x <= unsigned(pixel_x);
        pix_y <= unsigned(pixel_y);
        
        romSS_addr <= pix_y(3 downto 0) - ship_y_t(3 downto 0);
-- ROM column
        romSS_col <= pix_x(3 downto 0) - ship_x_l(3 downto 0);
-- Get row data
        romSS_data <= SHIP_ROM(to_integer(romSS_addr));
-- Get column bit
        romSS_bit <= romSS_data(to_integer(romSS_col));
        
        ship_x_l <= ship_x_reg;
        ship_x_r <= ship_x_l + SHIP_SIZE - 1;
        ship_y_t <= ship_y_reg;
        ship_y_b <= ship_y_t + SHIP_SIZE - 1;
        
        sq_spaceship_on <= '1' when (ship_x_l <= pix_x) and (pix_x <= ship_x_r) and (ship_y_t <= pix_y) and (pix_y <= ship_y_b) else '0';
        spaceship_rgb <= "111";

        spaceship_on <= '1' when (sq_spaceship_on = '1') and (romSS_bit = '1') else '0';
      
        bool_t <= '1' when (btn(0) = '1') and (ship_y_t > SHIP_SPEED) else '0';
        bool_l <= '1' when (btn(1) = '1') and (ship_x_l > SHIP_SPEED) else '0';
        bool_r <= '1' when (btn(2) = '1') and (ship_x_r < MAX_X - SHIP_SPEED - 1) else '0';
        bool_b <= '1' when (btn(3) = '1') and (ship_y_b < MAX_Y - SHIP_SPEED - 1) else '0';
        
        bool_tlrb <= (bool_t & bool_l & bool_r & bool_b);
        
        process(ship_x_reg, ship_y_reg, refr_tick, bool_tlrb, btn)
            begin
                ship_x_next <= ship_x_reg;
                ship_y_next <= ship_y_reg;
                if(refr_tick = '1') then
                    case bool_tlrb is
                        when "0000" =>
                            ship_x_next <= ship_x_reg;
                        when "0001" =>
                            ship_y_next <= ship_y_reg + SHIP_SPEED;
                        when "0010" =>
                            ship_x_next <= ship_x_reg + SHIP_SPEED;
                        when "0011" =>
                            ship_x_next <= ship_x_reg + SHIP_SPEED;
                            ship_y_next <= ship_y_reg + SHIP_SPEED;
                        when "0100" =>
                            ship_x_next <= ship_x_reg - SHIP_SPEED;
                        when "0101" =>
                            ship_x_next <= ship_x_reg - SHIP_SPEED;
                            ship_y_next <= ship_y_reg + SHIP_SPEED;
                        when "0110" =>
                            ship_x_next <= ship_x_reg;
                        when "0111" =>
                            ship_y_next <= ship_y_reg + SHIP_SPEED;
                        when "1000" =>
                            ship_y_next <= ship_y_reg - SHIP_SPEED;
                        when "1001" =>
                            ship_y_next <= ship_y_reg;
                        when "1010" =>
                            ship_y_next <= ship_y_reg - SHIP_SPEED;
                            ship_x_next <= ship_x_reg + SHIP_SPEED;
                        when "1011" =>
                            ship_x_next <= ship_x_reg + SHIP_SPEED;
                        when "1100" =>
                            ship_y_next <= ship_y_reg - SHIP_SPEED;
                            ship_x_next <= ship_x_reg - SHIP_SPEED;
                        when "1101" =>
                            ship_x_next <= ship_x_reg - SHIP_SPEED;
                        when "1110" =>
                            ship_y_next <= ship_y_reg - SHIP_SPEED;
                        when others =>
                            ship_x_next <= ship_x_reg;
                            ship_y_next <= ship_y_reg;
                    end case;
                end if;
        end process;

        romA1_addr <= pix_y(3 downto 0) - alien1_y_t(3 downto 0);
    -- ROM column
        romA1_col <= pix_x(3 downto 0) - alien1_x_l(3 downto 0);
    -- Get row data
        romA1_data <= ALIEN1_ROM(to_integer(romA1_addr));
    -- Get column bit
        romA1_bit <= romA1_data(to_integer(romA1_col));
            
        alien1_x_l <= alien1_x_reg;
        alien1_x_r <= alien1_x_l + SHIP_SIZE - 1;
        alien1_y_t <= alien1_y_reg;
        alien1_y_b <= alien1_y_t + SHIP_SIZE - 1;
    
        sq_alien1_on <= '1' when (alien1_x_l <= pix_x) and (pix_x <= alien1_x_r) and (alien1_y_t <= pix_y) and (pix_y <= alien1_y_b) else '0';
        alien1_rgb <= "101"; -- Purple color
        
        alien1_on <= '1' when (sq_alien1_on = '1') and (romA1_bit = '1') else '0';
        
        alien1_x_next <= alien1_x_reg + x1_delta_reg when (refr_tick = '1') else alien1_x_reg;
        alien1_y_next <= alien1_y_reg + y1_delta_reg when (refr_tick = '1') else alien1_y_reg;
        
        process(x1_delta_reg, y1_delta_reg, alien1_y_t, alien1_x_l, alien1_x_r, alien1_y_t, alien1_y_b, refr_tick)
            begin
                x1_delta_next <= x1_delta_reg;
                y1_delta_next <= y1_delta_reg;
                -- ball reached top, make offset positive
                if (alien1_y_t <= MAX_Y - 1) then
                    y1_delta_next <= AL1_V_P;
                -- reached bottom, make negative
                elsif (alien1_y_b >= 1) then
                    y1_delta_next <= AL1_V_N;
                elsif (alien1_x_l <= 1) then
                    x1_delta_next <= AL1_V_P;
                elsif (alien1_x_r >= (MAX_X - 1)) then
                    x1_delta_next <= AL1_V_N;
                end if;
        end process;
        
        
        romA2_addr <= pix_y(3 downto 0) - alien2_y_t(3 downto 0);
    -- ROM column
        romA2_col <= pix_x(3 downto 0) - alien2_x_l(3 downto 0);
    -- Get row data
        romA2_data <= ALIEN2_ROM(to_integer(romA2_addr));
    -- Get column bit
        romA2_bit <= romA2_data(to_integer(romA2_col));
        
        alien2_x_l <= alien2_x_reg;
        alien2_x_r <= alien2_x_l + SHIP_SIZE - 1;
        alien2_y_t <= alien2_y_reg;
        alien2_y_b <= alien2_y_t + SHIP_SIZE - 1;
    
        sq_alien2_on <= '1' when (alien2_x_l <= pix_x) and (pix_x <= alien2_x_r) and (alien2_y_t <= pix_y) and (pix_y <= alien2_y_b) else '0';
        alien2_rgb <= "001"; -- Blue color
    
        alien2_on <= '1' when (sq_alien2_on = '1') and (romA2_bit = '1') else '0';
        
        alien2_x_next <= alien2_x_reg + x2_delta_reg when (refr_tick = '1') else alien2_x_reg;
        alien2_y_next <= alien2_y_reg + y2_delta_reg when (refr_tick = '1') else alien2_y_reg;
        
        process(x2_delta_reg, y2_delta_reg, alien2_y_t, alien2_y_b, alien2_x_r, alien2_x_l, refr_tick)
            begin
                x2_delta_next <= x2_delta_reg;
                y2_delta_next <= y2_delta_reg;
                
                if(alien2_x_l <= 1) then
                    x2_delta_next <= AL2_V_P;
                elsif(alien2_x_r >= (MAX_X - 1)) then
                    x2_delta_next <= AL2_V_N;
                end if;
        end process;
        
        firing_ball_y_next <= (firing_ball_y_reg + firing_ball_y_delta_reg) when (refr_tick = '1') else firing_ball_y_reg;
        process (firing_ball_x_reg, firing_ball_y_reg, refr_tick, btn, ship_y_reg, ship_x_reg, ship_x_l) 
            begin
                firing_ball_x_next <= firing_ball_x_reg; 
                firing_ball_y_next <= firing_ball_y_reg; 
                if (refr_tick = '1') then 
                    if (btn(4) = '1') then  
                        firing_ball_x_next <= ship_x_l + 7; 
                        firing_ball_y_next <= ship_y_t;
                    elsif (firing_ball_y_reg < 1) then 
                        firing_ball_y_delta_next <= (others => '0'); 
                    end if; 
                end if; 
        end process;
        -- set coordinates of square firing ball 
        
        firing_ball_x_l <= firing_ball_x_reg; 
        firing_ball_y_t <= firing_ball_y_reg; 
        firing_ball_x_r <= firing_ball_x_l + FIRING_BALL_SIZE - 1; 
        firing_ball_y_b <= firing_ball_y_t + FIRING_BALL_SIZE - 1; 
        
        firing_rom_addr <= pix_y(2 downto 0) - firing_ball_y_t(2 downto 0);
        firing_rom_col <= pix_x(2 downto 0) - firing_ball_x_l(2 downto 0);
        firing_rom_data <= FIRING_BALL_ROM(to_integer(firing_rom_addr));
        firing_rom_bit <= firing_rom_data(to_integer(firing_rom_col));
        sq_firing_ball_on <= '1' when (firing_ball_x_l <= pix_x) and (pix_x <= firing_ball_x_r) and (firing_ball_y_t <= pix_y) and (pix_y <= firing_ball_y_b) else '0';
        firing_ball_on <= '1' when (sq_firing_ball_on = '1') and (firing_rom_bit = '1') else '0';
        firing_ball_rgb <= "110";
        
   -- set coordinates of square asteroids  
        asteroid_1_x_l <= asteroid_1_x_reg; 
        asteroid_1_y_t <= asteroid_1_y_reg; 
        asteroid_1_x_r <= asteroid_1_x_l + ASTEROID_1_SIZE - 1; 
        asteroid_1_y_b <= asteroid_1_y_t + ASTEROID_1_SIZE - 1; 
        
        asteroid_1_rom_addr <= pix_y(2 downto 0) - asteroid_1_y_t(2 downto 0);
        asteroid_1_rom_col <= pix_x(2 downto 0) - asteroid_1_x_l(2 downto 0);
        asteroid_1_rom_data <= asteroid_1_ROM(to_integer(asteroid_1_rom_addr));
        asteroid_1_rom_bit <= asteroid_1_rom_data(to_integer(asteroid_1_rom_col));
        sq_asteroid_1_on <= '1' when (asteroid_1_x_l <= pix_x) and (pix_x <= asteroid_1_x_r) and (asteroid_1_y_t <= pix_y) and (pix_y <= asteroid_1_y_b) else '0';
        asteroid_1_on <= '1' when (sq_asteroid_1_on = '1') and (asteroid_1_rom_bit = '1') else '0';
        
        asteroid1_rgb <= "011"; -- yellow

        asteroid_2_x_l <= asteroid_2_x_reg; 
        asteroid_2_y_t <= asteroid_2_y_reg; 
        asteroid_2_x_r <= asteroid_2_x_l + ASTEROID_2_SIZE - 1; 
        asteroid_2_y_b <= asteroid_2_y_t + ASTEROID_2_SIZE - 1; 
        
        asteroid_2_rom_addr <= pix_y(2 downto 0) - asteroid_2_y_t(2 downto 0);
        asteroid_2_rom_col <= pix_x(2 downto 0) - asteroid_2_x_l(2 downto 0);
        asteroid_2_rom_data <= asteroid_2_ROM(to_integer(asteroid_2_rom_addr));
        asteroid_2_rom_bit <= asteroid_2_rom_data(to_integer(asteroid_2_rom_col));
        sq_asteroid_2_on <= '1' when (asteroid_2_x_l <= pix_x) and (pix_x <= asteroid_2_x_r) and (asteroid_2_y_t <= pix_y) and (pix_y <= asteroid_2_y_b) else '0';
        asteroid_2_on <= '1' when (sq_asteroid_2_on = '1') and (asteroid_2_rom_bit = '1') else '0';

        asteroid2_rgb <= "111"; -- white
        
        asteroid_3_x_l <= asteroid_3_x_reg; 
        asteroid_3_y_t <= asteroid_3_y_reg; 
        asteroid_3_x_r <= asteroid_3_x_l + ASTEROID_3_SIZE - 1; 
        asteroid_3_y_b <= asteroid_3_y_t + ASTEROID_3_SIZE - 1; 
        
        asteroid_3_rom_addr <= pix_y(2 downto 0) - asteroid_3_y_t(2 downto 0);
        asteroid_3_rom_col <= pix_x(2 downto 0) - asteroid_3_x_l(2 downto 0);
        asteroid_3_rom_data <= asteroid_3_ROM(to_integer(asteroid_3_rom_addr));
        asteroid_3_rom_bit <= asteroid_3_rom_data(to_integer(asteroid_3_rom_col));
        sq_asteroid_3_on <= '1' when (asteroid_3_x_l <= pix_x) and (pix_x <= asteroid_3_x_r) and (asteroid_3_y_t <= pix_y) and (pix_y <= asteroid_3_y_b) else '0';
        asteroid_3_on <= '1' when (sq_asteroid_3_on = '1') and (asteroid_3_rom_bit = '1') else '0';

        asteroid3_rgb <= "110"; -- orange
        
        asteroid_1_x_next <= (asteroid_1_x_reg + asteroid_1_x_delta_reg) when (refr_tick = '1') else asteroid_1_x_reg;
        asteroid_1_y_next <= (asteroid_1_y_reg + asteroid_1_y_delta_reg) when (refr_tick = '1') else asteroid_1_y_reg;
        asteroid_2_x_next <= (asteroid_2_x_reg + asteroid_2_x_delta_reg) when (refr_tick = '1') else asteroid_2_x_reg;
        asteroid_2_y_next <= (asteroid_2_y_reg + asteroid_2_y_delta_reg) when (refr_tick = '1') else asteroid_2_y_reg;
        asteroid_3_x_next <= (asteroid_3_x_reg + asteroid_3_x_delta_reg) when (refr_tick = '1') else asteroid_3_x_reg;
        asteroid_3_y_next <= (asteroid_3_y_reg + asteroid_3_y_delta_reg) when (refr_tick = '1') else asteroid_3_y_reg;
        
        process(asteroid_1_x_delta_reg, asteroid_1_y_delta_reg, asteroid_1_x_l, asteroid_1_y_t, asteroid_1_x_r, asteroid_1_y_b, ship_y_t, ship_y_b, ship_x_r, ship_x_l) 
            begin 
                asteroid_1_x_delta_next <= asteroid_1_x_delta_reg; 
                asteroid_1_y_delta_next <= asteroid_1_y_delta_reg; 
                
                if asteroid_1_y_t < 1 then 
                    asteroid_1_y_delta_next <= ASTEROID_1_V_P; 
                elsif asteroid_1_y_b > (MAX_Y - 1) then 
                    asteroid_1_y_delta_next <= ASTEROID_1_V_N; 
                elsif (SHIP_X_L <= asteroid_1_x_r) and (asteroid_1_x_r <= SHIP_X_R) and (ship_y_t <= asteroid_1_y_b) and (ship_y_b <= asteroid_1_y_t) then 
                    asteroid_1_x_delta_next <= ASTEROID_1_V_N;
                end if; 
            end process; 
            
        process(asteroid_2_x_delta_reg, asteroid_2_y_delta_reg, asteroid_2_x_l, asteroid_2_x_r, asteroid_2_y_t, asteroid_2_y_b, ship_y_t, ship_y_b, ship_x_r, ship_x_l) 
           begin 
               asteroid_2_x_delta_next <= asteroid_2_x_delta_reg; 
               asteroid_2_y_delta_next <= asteroid_2_y_delta_reg; 
               if asteroid_2_y_t < 1 then 
                   asteroid_2_y_delta_next <= ASTEROID_2_V_P; 
               elsif asteroid_2_y_b > (MAX_Y - 1) then 
                   asteroid_2_y_delta_next <= ASTEROID_2_V_N; 
               elsif (SHIP_X_L <= asteroid_2_x_r) and (asteroid_2_x_r <= SHIP_X_R) and (ship_y_t <= asteroid_2_y_b) and (ship_y_b <= asteroid_2_y_t) then 
                   asteroid_2_x_delta_next <= ASTEROID_2_V_N; 
               end if; 
        end process; 

 

        process(asteroid_3_x_delta_reg, asteroid_3_y_delta_reg, asteroid_3_x_l, asteroid_3_y_t, asteroid_3_x_r, asteroid_3_y_b, ship_y_t, ship_y_b, ship_x_l, ship_x_r) 
            begin 
                asteroid_3_x_delta_next <= asteroid_3_x_delta_reg; 
                asteroid_3_y_delta_next <= asteroid_3_y_delta_reg; 
                if asteroid_3_y_t < 1 then 
                    asteroid_3_y_delta_next <= ASTEROID_3_V_P;
                elsif asteroid_3_y_b > (MAX_Y - 1) then 
                    asteroid_3_y_delta_next <= ASTEROID_3_V_N;
                elsif (SHIP_X_L <= asteroid_3_x_r) and (asteroid_3_x_r <= SHIP_X_R) and (ship_y_t <= asteroid_3_y_b) and (ship_y_b <= asteroid_3_y_t) then 
                    asteroid_3_x_delta_next <= ASTEROID_3_V_N; 
                end if; 
        end process; 
        
-- map coordinates of firing ball  
        firing_rom_addr <= pix_y(2 downto 0) - firing_ball_y_t(2 downto 0); 
        firing_rom_col <= pix_x(2 downto 0) - firing_ball_x_l(2 downto 0); 
        firing_rom_data <= FIRING_BALL_ROM(to_integer(firing_rom_addr)); 
         
        process(video_on, spaceship_on, spaceship_rgb)
            begin
                if (video_on = '0') then
                        graph_rgb <= "000"; -- blank
                else
                    if (spaceship_on = '1') then
                        graph_rgb <= spaceship_rgb;
                    elsif (alien1_on = '1') then
                        graph_rgb <= alien1_rgb;
                    elsif(alien2_on = '1') then
                        graph_rgb <= alien2_rgb;
                    elsif(firing_ball_on = '1') then
                        graph_rgb <= firing_ball_rgb;    
                    elsif (asteroid_1_on = '1') then
                        graph_rgb <= asteroid1_rgb;
                    elsif (asteroid_2_on = '1') then
                        graph_rgb <= asteroid2_rgb;
                    elsif (asteroid_3_on = '1') then
                        graph_rgb <= asteroid3_rgb;
                    else
                        graph_rgb <= "000"; -- black bkgnd
                    end if;
                end if;
        end process;
        
        hit_cnter_next <= hit_cnter_reg + 1 when 
            (alien1_x_l <= ship_x_r) and 
            (alien1_x_r > ship_x_l) and 
            (alien1_y_b <= ship_y_t) and 
            (refr_tick = '1') else hit_cnter_reg;
            
        hit_cnt <= std_logic_vector(hit_cnter_reg);
end si_arch;
