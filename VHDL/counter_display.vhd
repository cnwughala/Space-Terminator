----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/06/2024 11:44:01 AM
-- Design Name: 
-- Module Name: counter_display - Behavioral
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

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/25/2024 12:39:02 AM
-- Design Name: 
-- Module Name: counter_display - rtl
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity counter_disp is
    Port (
        pixel_x : in STD_LOGIC_VECTOR (9 downto 0);
        pixel_y : in STD_LOGIC_VECTOR (9 downto 0);
        hit_cnt: in STD_LOGIC_VECTOR (1 downto 0);
        sq_hit_cnter_on_output: out std_logic;
        graph_rgb: out std_logic_vector(2 downto 0)
    );
    end counter_disp;
    
architecture Behavioral of counter_disp is
-- x, y coordinates (0,0 to (639, 479)
    signal pix_x, pix_y: unsigned(9 downto 0);
    -- signal that stores the unsigned 'hit_cnt' value
    signal hit_cnter: unsigned(1 downto 0);
    -- Square cnter size and boundaries
    constant CNT_SIZE: integer := 16;
    constant HIT_CNT_X_L: integer := 610;
    constant HIT_CNT_X_R: integer:= HIT_CNT_X_L + CNT_SIZE - 1;
    constant HIT_CNT_Y_T: integer := 80;
    constant HIT_CNT_Y_B: integer:= HIT_CNT_Y_T + CNT_SIZE - 1;
    -- new data type to store the 16x16 rom images of counter values 0-7
    type counter_type is array(0 to 15) of std_logic_vector(0 to 15);
    -- signal that stores the rom image of the current cnter value
    signal cnter_rom_current: counter_type;
    -- constant rom images for 0-7
    constant CNTER_ROM_0: counter_type:= (
        "0000011111110000",
        "0001111111111100",
        "0111000000001110",
        "0110000000000110",
        "1110000000000111",
        "1110000000000111",
        "1110000000000111",
        "1110000000000111",
        "1110000000000111",
        "1110000000000111",
        "1110000000000111",
        "1110000000000111",
        "1110000000000111",
        "0111000000001110",
        "0011111111111100",
        "0000111111111000");
--- Write your own VHDL code below:
--- Initialize images for other CNTER_ROM VALUES (1-7)
-- signals to store the row and column indexes of the current cnter rom
     constant CNTER_ROM_1: counter_type:= (
        "0000001111110000",
        "0000111111110000",
        "0001111011110000",
        "0011110011110000",
        "0111100011110000",
        "1111000011110000",
        "0000000011110000",
        "0000000011110000",
        "0000000011110000",
        "0000000011110000",
        "0000000011110000",
        "0000000011110000",
        "0000000011110000",
        "0000000011110000",
        "0000000011110000",
        "0000000011110000");
        
     constant CNTER_ROM_2: counter_type:= (
        "1111111111111111",
        "1111111111111111",
        "0000000000011111",
        "0000000000011111",
        "0000000000011111",
        "0000000000011111",
        "0000000000011111",
        "1111111111111111",
        "1111111111111111",
        "1111111111111111",
        "1111100000000000",
        "1111100000000000",
        "1111100000000000",
        "1111100000000000",
        "1111111111111111",
        "1111111111111111");
        
      constant CNTER_ROM_3: counter_type:= (
        "1111111111111111",
        "1111111111111111",
        "1111111111111111",
        "0000000000011111",
        "0000000000011111",
        "0000000000011111",
        "1111111111111111",
        "1111111111111111",
        "1111111111111111",
        "1111111111111111",
        "0000000000011111",
        "0000000000011111",
        "0000000000011111",
        "1111111111111111",
        "1111111111111111",
        "1111111111111111");

    signal rom_addr_cnter, rom_col_cnter: unsigned(3 downto 0);
    -- signals to store the row data and the rom_bit
    signal rom_data_cnter: std_logic_vector(0 to 15);
    signal rom_bit_cnter: std_logic;
    -- signal to indicate if scan coord is within the square area of
    --- the counter
    signal sq_hit_cnter_on: std_logic;
    -- signals to indicate if the image of current cnter value is
    --- displayed
    signal hit_cnter_cur_val_on: std_logic;
    -- hit cnter value color
    signal hit_cnter_rgb: std_logic_vector(2 downto 0);
    -- signals that store unsigned values of the square counter boundaries
    signal hit_cnt_y_t_u: unsigned(9 downto 0);
    signal hit_cnt_x_l_u: unsigned(9 downto 0);

    begin
        pix_x <= unsigned(pixel_x);
        pix_y <= unsigned(pixel_y);
        hit_cnter <= unsigned(hit_cnt);
    -- Write your VHDL code below:
    -- Assert 'sq_hit_cnter_on' by checking if the pixel is within the area
    --- of the square hit_counter;
    -- Note: the square area is a fixed area shared by 8 counter values
    --- Write your VHDL code: complete "with select" statement below:
    --- Here we use a signal 'cnter_rom_current' to store the actual
    --- ROM image to be displayed which depends on the current cnter value.
    -- Assign the corresponding ROM image constant to 'cnter_rom_current'
    --- depending on the value of 'hit_cnter'
            
        sq_hit_cnter_on <= '1' when (HIT_CNT_X_L <= pix_x) and (pix_x <= HIT_CNT_X_R) and (HIT_CNT_Y_T <= pix_y) and (pix_y <= HIT_CNT_Y_B) else '0';
    
        with to_integer(hit_cnter) select
        cnter_rom_current <= CNTER_ROM_3 when 0,
                             CNTER_ROM_2 when 1,
                             CNTER_ROM_1 when 2,
                             CNTER_ROM_0 when others;
        --- Complete the above "with-select" statement
        -- type conversion to unsigned values
        hit_cnt_y_t_u <= to_unsigned(HIT_CNT_Y_T, 10);
        hit_cnt_x_l_u <= to_unsigned(HIT_CNT_X_L, 10);
        -- Obtain row and col indexes
        rom_addr_cnter <= pix_y(3 downto 0) - hit_cnt_y_t_u(3 downto 0);
        rom_col_cnter <= pix_x(3 downto 0) - hit_cnt_x_l_u(3 downto 0);
        -- map scan coord to rom_bit using addr/col for current cnter value;
        rom_data_cnter <= cnter_rom_current(to_integer(rom_addr_cnter));
        rom_bit_cnter <= rom_data_cnter(to_integer(rom_col_cnter));
        --- Write your VHDL code below:
        -- assert 'hit_cnter_cur_val_on' by checking
        hit_cnter_cur_val_on <= '1' when (sq_hit_cnter_on = '1') and (rom_bit_cnter = '1') else '0';
        --- 'sq_hit_cnter_on' and 'rom_bit_cnter'
        -- set the cnter value color
        hit_cnter_rgb <= "001";
        --- Write your VHDL code below:
        -- set graph_rgb
        
        graph_rgb <= hit_cnter_rgb when (sq_hit_cnter_on = '1') and (hit_cnter_cur_val_on = '1') else "111";
        -- assign output sq_hit_cnter_on_output
        sq_hit_cnter_on_output <= sq_hit_cnter_on;
        
end Behavioral;
