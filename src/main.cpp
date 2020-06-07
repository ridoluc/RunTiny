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

// const uint8_t HELLO[70] ={
//     0xff,0x08,0x08,0x08,0x08,0xff,0x00, //H
//     0xff,0x89,0x89,0x89,0x89,0x81,0x00, //E
//     0xff,0x80,0x80,0x80,0x80,0x80,0x00, //L
//     0xff,0x80,0x80,0x80,0x80,0x80,0x00, //L
//     0x3c,0x42,0x81,0x81,0x81,0x42,0x3c, //O
//     0x00,0x00,0x00,0x00,0x00,0x00,0x00, //' '
//     0x01,0x01,0x01,0xff,0x01,0x01,0x01, //T
//     0x00,0x81,0x81,0xff,0x81,0x81,0x00, //I
//     0xff,0x02,0x04,0x08,0x10,0xff,0x00, //N
//     0x01,0x06,0x08,0xf0,0x08,0x06,0x01  //Y
// };

// const uint8_t HELLO1[56] ={
//     0x00,0x00,0x00,0x00,0x00,0x00,0x00, //' '
//     0x00,0x00,0x00,0x00,0x00,0x00,0x00, //' '
//     0x00,0x00,0x00,0x00,0x00,0x00,0x00, //' '
//     0x00,0x00,0x00,0x00,0x00,0x00,0x00, //' '
//     0xff,0x08,0x08,0x08,0x08,0xff,0x00, //H
//     0xff,0x89,0x89,0x89,0x89,0x81,0x00, //E
//     0xff,0x80,0x80,0x80,0x80,0x80,0x00, //L
//     0xff,0x80,0x80,0x80,0x80,0x80,0x00, //L
//     // 0x3c,0x42,0x81,0x81,0x81,0x42,0x3c, //O
// };

// const uint8_t Sprite1[7] = {
//     0x1c, 0xf8, 0x38, 0xfe, 0x1f, 0x07, 0x02
//     // 0xc1,0x8f,0x83,0xef,0xf1,0x70,0x20
// };

// I2C Functions declaration
void start();
void stop();
extern "C" {bool Tx(uint8_t);}
uint8_t Rx(uint8_t);

extern "C" {void print(uint8_t);};

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

    /* Set position for the text */
    // start();
    // Tx(ADDR);
    // Tx(0x00);
    // Tx(0x21);   // Set Column
    // Tx(0x19);   // Start at column 25
    // Tx(0x7F);   // End at 128
    // Tx(0x22);   // Set Page
    // Tx(0x01);   // Start at page 1
    // Tx(0x01);   // End at page 1
    // stop();

    // /* Write the message*/
    // start();
    // Tx(ADDR);
    // Tx(0x40);
    // for (uint8_t i = 0; i < 70; i++)
    // {
    //     Tx(HELLO[i]);
    // }
    // stop();


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

    // start();
    // Tx(ADDR);
    // Tx(0x40);
    // while(page--){
    //     while(cols--){
    //     Tx( Sprite1[cols]  << h >>8*page );

    //     };
    //     cols=7;
    //     // page--;
    // };
    // stop();
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

        // Print column
        start();
        Tx(ADDR);
        Tx(0x40);

        print(h);

        // while (cols--)
        // {
        //     *c = (Sprite1[cols] << h);

        //     Tx(c[0]);
        //     Tx(c[1]);
        //     Tx(c[2]);
        //     Tx(c[3]);
        // };
        stop();

        // while(page--){
        //     while(cols--){
        //     // Tx( Sprite1[cols]  << h >> 8*page );
        //         if(h<page*8)Tx(Sprite1[cols]>>(page*8-h));
        //         else Tx(Sprite1[cols]<<(h-page*8));

        //     };
        //     cols=7;
        // };
        // h+=3;
    }
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