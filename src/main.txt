/**
 * This works
 * 
 * things to check:
 * - sda and scl pins defined first in the pico i2c library
 * - the oled breakout doeas not need the pull up resistors
 * - remember attiny10 needs 5v
 * 
 * */

#include <avr/io.h>
#include <stdint.h>
#include <util/delay.h>

#define H_MAX 24

#define PI2C_SDA PB0
#define PI2C_SCL PB1

#define OUT_REG PORTB
#define IN_REG PINB

#define SDA_ON (OUT_REG |= (1 << PI2C_SDA))
#define SDA_OFF (OUT_REG &= ~(1 << PI2C_SDA))
#define SCL_ON (OUT_REG |= (1 << PI2C_SCL))
#define SCL_OFF (OUT_REG &= ~(1 << PI2C_SCL))

#define SDA_READ (IN_REG & (1 << PI2C_SDA))
#define SCL_READ (IN_REG & (1 << PI2C_SCL))

#define I2C_READ 0x01
#define I2C_WRITE 0x00

#define BIT8_TO_BIT16(a, b) ((b << 8) + a)

#define ADDR 0b01111000 //OLED Address plus write bit

inline void dly() { __asm__("NOP"); };

const uint8_t InitLen = 26;

const uint8_t Init[26] = {
    0xAE,       // Display OFF
    0xA8, 0x1F, // set multiplex (HEIGHT-1): 0x1F for 128x32, 0x3F for 128x64
    0xD3, 0x00, // Display offset to 0
    0x40,       // Set display start line to 0
    0x8D, 0x14, // Charge pump enabled
    0x20, 0x01, // Memory addressing mode 0x00 Horizontal 0x01 Vertical
    0xDA, 0x02, // Set COM Pins hardware configuration to sequential
    0x81, 0x80, // Set contrast
    0xD9, 0xF1, // Set pre-charge period
    0xDB, 0x40, // Set vcom detect

    0x22, 0x00, 0x03, // Page min to max
    0x21, 0x00, 0x7F, // Column min to max

    0xAF // Display on
};

// I2C Functions declaration
extern "C"{void start();}
extern "C"{void stop();}
extern "C"{void Tx(uint8_t);}
// uint8_t Rx(uint8_t);


extern "C"{void set_draw_region(uint16_t, uint16_t);}


extern "C"{void print_player(uint8_t);}
extern "C"{void print_enemies(void);}
extern "C"{void update_enemy_pos(void);}
extern "C"{void print_score(void);}

int8_t enemy_pos[3] = {20, 50, 90};

extern "C"{void clear_display(void);}

void clear()
{
    start();
    Tx(ADDR);
    Tx(0x40);
    uint8_t i = 255;
    do
    {
        Tx(0x00);
        Tx(0x00);

    }while(i--);
    stop();
}

int main(void)
{

    DDRB = 3;
    PUEB = (1 << PUEB2);

    _delay_ms(100);

    /* Display Initialization */
    start();
    Tx(ADDR);
    Tx(0x00);
    for (uint8_t i = 0; i < InitLen; i++)
    {
        Tx(Init[i]);
    }

    stop();

    /* Clear the display */
    clear_display();

    uint8_t h = 0;

  

    for (;;)
    {

        // page = 4;
        _delay_ms(500);

        if (!(PINB & (1 << PINB2)))
            h += 4;
        else if (h)
            h -= 4;
        // if(h>H_MAX) PORTB =1;   // to do
        // if(!h) PORTB =0;        // to do

        if (h > H_MAX)
            h = 0;

        update_enemy_pos();

        set_draw_region(BIT8_TO_BIT16(100, 117), BIT8_TO_BIT16(0, 0));

        print_score();

        set_draw_region(BIT8_TO_BIT16(10, 16), BIT8_TO_BIT16(0, 3));

        print_player(h);
        set_draw_region(BIT8_TO_BIT16(0, 127), BIT8_TO_BIT16(3, 3));

        print_enemies();


    }
}


