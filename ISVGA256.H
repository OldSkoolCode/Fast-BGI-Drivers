/*****************************************
 * Defines for  ISVGA256.BGI   driver    *
 *        Thomas Design                  *
 *        December 29, 1989              *
 * Vers 2.0                              *
 *****************************************/

#define  ATI320x200    0        /* ATI VGA graphics modes */
#define  ATI640x400    1
#define  ATI640x480    2
#define  ATI800x600    3

#define  DVGA320x200   4        /* Orchid ProDesigner Plus */
#define  DVGA640x350   5        /* (Tseng Labs 3000 chipset) */
#define  DVGA640x480   6
#define  DVGA800x600   7

#define  PVGA320x200   8        /* Paradise (Western Digital) */
#define  PVGA640x400   9
#define  PVGA640x480   0x0a

#define  TEC320x200    0x0b     /* Tecmar */
#define  TEC640x350    0x0c
#define  TEC640x400    0x0d
#define  TEC640x480    0x0e
#define  TEC800x600    0x0f

#define  VID320x200    0x10     /* Video 7 (Headland Technologies) */
#define  VID640x400    0x11
#define  VID640x480    0x12
#define  VID720x540    0x13
#define  VID800x600    0x14

#define  TRID320x200   0x15     /* Trident chipsets */
#define  TRID640x400   0x16
#define  TRID640x480   0x17
#define  TRID800x600   0x18

#define  CHIP320x200   0x19     /* Chips and Tech chipset */
#define  CHIP640x400   0x1a
#define  CHIP640x480   0x1b
#define  CHIP800x600   0x1c

#define  AHDA320x200   0x1d     /* Ahead Systems VGA wizard deluxe (Rev A) */
#define  AHDA640x400   0x1e
#define  AHDA640x480   0x1f
#define  AHDA800x600   0x20

#define  AHDB320x200   0x21     /* Ahead Systems VGA wizard deluxe (Rev B) */
#define  AHDB640x400   0x22
#define  AHDB640x480   0x23
#define  AHDB800x600   0x24
#define  AHDB1024x768  0x25

#define  EVRX320x200   0x26     /* Everex */
#define  EVRX640x400   0x27
#define  EVRX640x480   0x28
#define  EVRX800x600   0x29

#define  OAK320x200    0x2a     /* Oak Technology */
#define  OAK640x480    0x2b
#define  OAK800x600    0x2c

#define  TSG320x200    0x2d     /* Orchid ProDesigner Plus II */
#define  TSG640x400    0x2e     /* (Tseng Labs 4000 chipset) */
#define  TSG640x800    0x2f
#define  TSG800x600    0x30
#define  TSG1024x768   0x31

#define  GEN320x200    0x32     /* Genoa GVGA */
#define  GEN640x400    0x33
#define  GEN640x480    0x34
#define  GEN800x600    0x35

void               _Cdecl ISVGA256_driver(void);
extern int far     _Cdecl ISVGA256_driver_far[];
