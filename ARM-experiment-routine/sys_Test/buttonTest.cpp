//------------------------- Include -----------------------//
#include "..\driver\iCore3_leds.hpp"
#include "..\driver\iCore3_buttons.hpp"
#include "..\fwlib\inc\stm32f4xx_gpio.h"

void button_test_1(void) {
    int i;
    static int work_status = 0;
    static int key_status = 1;

    iCore3_leds led;
    iCore3_Buttons key;

    led.initialize();
    key.initialize();

    while (1) {
        if (key.get_key()) key_status = 1;

        if (key_status == 1) {
            if (!key.get_key()) {
                for (i = 0; i < 10000; i++)
                    ;
                if (!key.get_key()) {
                    key_status = 0;
                    work_status += 1;
                    if (work_status > 2) work_status = 0;
                    switch (work_status) {
                        case 0:
                            led.RED_ON();
                            led.GREEN_OFF();
                            led.BLUE_OFF();
                            break;
                        case 1:
                            led.RED_OFF();
                            led.GREEN_ON();
                            led.BLUE_OFF();
                            break;
                        case 2:
                            led.RED_OFF();
                            led.GREEN_OFF();
                            led.BLUE_ON();
                            break;
                        default:

                            break;
                    }
                }
            }
        }
    }
}
