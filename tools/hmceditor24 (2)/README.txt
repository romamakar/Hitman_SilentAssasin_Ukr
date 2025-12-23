Hitman: Contracts TEX Editor v2.4                               MPL open source
©Copyright 2004 Alexande "Elbereth" Devilliers                       20-06-2004
===============================================================================

What is this tool:
------------------

This tool can export\import textures from\into Hitman: Contracts (Hitman 2 too
I heard) .TEX files:

       TEX    TEX  Import
   Texture MipMap  Export   Description
      RGBA     No     TGA   Targa 32Bpp with alpha channel
      RGBA    Yes     TGA   Targa 32Bpp with alpha channel
                            MipMap is generated automatically using Lanczos3
                            algorithm when importing.
      DXT1     No     DDS   Microsoft DirectDraw Surface DXT1 compressed
                            (without mipmaps)
      DXT1    Yes     DDS   Microsoft DirectDraw Surface DXT1 compressed
                            (with same number of mipmaps as in TEX file)
      DXT3     No     DDS   Microsoft DirectDraw Surface DXT3 compressed
                            (without mipmaps)
      DXT3    Yes     DDS   Microsoft DirectDraw Surface DXT3 compressed
                            (with same number of mipmaps as in TEX file)
      PALN      -     TGA   Targa 32Bpp with alpha channel with same number of
                            unique colors as in TEX file.

It supports PC and Xbox version of the game.

To enable Xbox support (automatic textures unswizzle/swizzle):
- click on "Options" button
- check the "Xbox mode" option
- click on "OK" button.

Note: Doing that while using PC version of the game will result in scrambled
      imported RGBA and PALN textures in game.
      

IMPORTANT MESSAGE:
------------------

Backup your ZIP files before modifying them.


How to modify textures of Hitman: Contracts:
--------------------------------------------

1. Open the ZIP files found in the Scenes subdirectory of Hitman: Contracts.
   (you must keep the paths from ZIP files)

   Ex: Scenes\MainMenu.zip
       Scenes\C00-1\C00-1_MAIN.zip
       
   The program will unzip the .TEX file and open it automatically.
   Export any texture you are willing to edit (only RGBA, DXT1 and DXT3 are
   supported).

   If you are willing to do batch export of RGBA textures you can use Dragon
   UnPACKer 5 with latest driver and convert plugin.

2. Modify the TGA\DDS texture.
   PhotoShop is highly recommended (it supports perfectly TGA 32bpp with alpha
   and a DDS plugin is available from nVidia for free).
   Get the PhotoShop DDS plugin from:
   http://developer.nvidia.com/object/nv_texture_tools.html
   
   You can also use the free tool The Gimp 2.0 which has TGA 32bpp with alpha
   support too and the nvDXT standalone tool allowing to convert DDS files to
   TGA.
   http://mmmaybe.gimp.org/windows/
   
3. Using HMCEditor, import the DDS\TGA texture back into the TEX file:
   - Select the texture to replace in the list (only RGBA, DXT1 and DXT3 are
     supported)
   - The Import button will enable
   - Click on import and select your TGA\DDS file
   
4. When you have finished editing the TEX file, click on Update ZIP!
   DO NOT FORGET THIS STEP!!!!

5. Run Hitman: Contracts to observe your changes!


Getting latest version:
-----------------------

You can download latest version here:
http://download.elberethzone.net/hmc/

Check the forum for more information:
http://forum.elberethzone.net/viewforum.php?f=8

===============================================================================