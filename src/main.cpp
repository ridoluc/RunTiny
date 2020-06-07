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
extern "C" {void start();}
extern "C" {void stop();}
extern "C" {void set_draw_region(uint8_t, uint8_t, uint8_t, uint8_t );}
extern "C" {bool Tx(uint8_t);}
uint8_t Rx(uint8_t);

extern "C" {void print_player(uint8_t);};
extern "C" {void print_enemies(void);}

void clear()
{
    start();
    Tx(ADDR);
    Tx(0x40);
    for (uint8_t i = 0; i < 128; i++)
    {
        Tx(0x00);
        Tx(0x00);
        Tx(0x00);
        Tx(0x00);
    }
    stop();
}

int main(void)
{

    DDRB = 3;
    PUEB = (1<<PUEB2);

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
    clear();



    uint8_t h = 0;

    start();
    Tx(ADDR);
    Tx(0x00);
    Tx(0x21); // Set Column
    Tx(10);    // Start column
    Tx(16);    // End at
    Tx(0x22); // Set Page
    Tx(0);    // Start at page 1
    Tx(3);    // End at page 4
    stop();

    // set_draw_region(10,16,0,3);

    for (;;)
    {

        // page = 4;
        _delay_ms(50);

        if(!(PINB & (1<<PINB2))) h+=4;
        else if(h) h-=4;
        // if(h>H_MAX) PORTB =1;   // to do
        // if(!h) PORTB =0;        // to do

        if (h > H_MAX)
            h = 0;

        start();
        Tx(ADDR);
        Tx(0x00);
        Tx(0x21); // Set Column
        Tx(0);    // Start column
        Tx(127);    // End at
        Tx(0x22); // Set Page
        Tx(3);    // Start at page 4
        Tx(3);    // End at page 4
        stop();


        print_enemies();

        // start();
        // Tx(ADDR);
        // Tx(0x00);
        // Tx(0x21); // Set Column
        // Tx(10);    // Start column
        // Tx(16);    // End at
        // Tx(0x22); // Set Page
        // Tx(0);    // Start at page 1
        // Tx(3);    // End at page 4
        // stop();
        // print_player(h);
 

        // h+=3;
    }
}

void set_draw_region(uint8_t col_start,uint8_t col_end, uint8_t pg_start, uint8_t pg_end){
    start();
    Tx(ADDR);
    Tx(0x00);
    Tx(0x21); // Set Column
    Tx(col_start);    // Start column
    Tx(col_end);    // End at
    Tx(0x22); // Set Page
    Tx(pg_start);    // Start at page 1
    Tx(pg_end);    // End at page 4
    stop();
}

/*  i2c start sequence */
void start()
{
    SDA_ON;
    dly();
    SCL_ON;
    dly();
    SDA_OFF;
    dly();
    SCL_OFF;
    dly();
}

/*  i2c stop sequence */
void stop()
{
    SDA_OFF;
    dly();
    SCL_ON;
    dly();
    SDA_ON;
    dly();
}

/* Transmit 8 bit data to slave */
bool Tx(uint8_t dat)
{
    for (uint8_t i = 0; i < 8; i++)
    {
        (dat & 0x80) ? SDA_ON : SDA_OFF;
        dat <<= 1;
        dly();
        SCL_ON;
        dly();
        SCL_OFF;
        dly();
    }

    SDA_ON;
    SCL_ON;
    dly();
    bool ack = !SDA_READ; // Acknowledge bit
    SCL_OFF;
    return ack;
}

/* Receive 8 bit packet data from the slave. Check for clock stretching*/
uint8_t Rx(bool ack)
{
    uint8_t dat = 0;
    SDA_ON;
    for (uint8_t i = 0; i < 8; i++)
    {
        dat <<= 1;
        do
        {
            SCL_ON;
        } while (SCL_READ == 0); //SCL stretching
        dly();
        if (SDA_READ)
            dat |= 1;
        dly();
        SCL_OFF;
    }
    ack ? SDA_OFF : SDA_ON;
    SCL_ON;
    dly();
    SCL_OFF;
    SDA_ON;
    return (dat);
}