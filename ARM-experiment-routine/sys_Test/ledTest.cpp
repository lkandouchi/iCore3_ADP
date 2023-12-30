//------------------------- Include -----------------------//
#include "..\driver\iCore3_leds.hpp"
#include "..\fwlib\inc\stm32f4xx_gpio.h"

void led_test_1(void) {
    int i;
    iCore3_leds led;
    led.initialize();

    while (1) {
        led.RED_ON();
        led.GREEN_OFF();
        led.BLUE_OFF();
        for (i = 0; i < 10000000; i++)
            ;
        led.RED_OFF();
        led.GREEN_ON();
        led.BLUE_OFF();
        for (i = 0; i < 10000000; i++)
            ;
        led.RED_OFF();
        led.GREEN_OFF();
        led.BLUE_ON();
        for (i = 0; i < 10000000; i++)
            ;
    }
}
