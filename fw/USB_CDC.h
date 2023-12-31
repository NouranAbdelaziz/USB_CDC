#define USB_CDC_BASE 0x00000000
#define TX_DATA_REG_ADDR                 (USB_CDC_BASE + 0x0000)
#define RX_DATA_REG_ADDR                 (USB_CDC_BASE + 0x0004)
#define TX_FIFO_LEVEL_REG_ADDR           (USB_CDC_BASE + 0x0008)
#define RX_FIFO_LEVEL_REG_ADDR           (USB_CDC_BASE + 0x000C)
#define TX_FIFO_TH_REG_ADDR              (USB_CDC_BASE + 0x0010)
#define RX_FIFO_TH_REG_ADDR              (USB_CDC_BASE + 0x0014)
#define ICR_REG_ADDR                     (USB_CDC_BASE + 0x0018)
#define RIS_REG_ADDR                     (USB_CDC_BASE + 0x001C)
#define IM_REG_ADDR                      (USB_CDC_BASE + 0x0020)
#define MIS_REG_ADDR                     (USB_CDC_BASE + 0x0024)