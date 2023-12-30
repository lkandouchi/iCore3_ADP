
#pragma once

#include "..\fwlib\inc\stm32f4xx_gpio.h"
#include "..\fwlib\inc\stm32f4xx_rcc.h"

class iCore3_Buttons {
    private:
    public:
    iCore3_Buttons(/* args */) {
    }
    ~iCore3_Buttons() {
    }

    int initialize(void) {
	GPIO_InitTypeDef   GPIO_uInitStructure;

	RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOH,ENABLE);
	GPIO_uInitStructure.GPIO_Pin = GPIO_Pin_15;                            //Set the IO port of the connection button
	GPIO_uInitStructure.GPIO_Mode = GPIO_Mode_IN;                          
	GPIO_uInitStructure.GPIO_Speed = GPIO_Speed_100MHz;                   
	GPIO_uInitStructure.GPIO_PuPd = GPIO_PuPd_NOPULL;                      

	GPIO_Init(GPIOH, &GPIO_uInitStructure);

	return 0;
    }

    int get_key(void) {
        if( GPIO_ReadInputDataBit(GPIOH,GPIO_Pin_15) == 0) {
            return 1;
        } else {
            return 0;
        }
    }
};
