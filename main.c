#include <stdio.h>
#include <stdlib.h>

#include <SDL2/SDL.h>

#ifdef __cplusplus
extern "C" {
#endif
 int func(char *a, char* b, int contrast, int tryb);
#ifdef __cplusplus
}
#endif

const int WIDTH = 640, HEIGHT = 360;
int newContrast = 0;
int wybor = 2;
const int maxContrast = 255;
const int minContrast = -255;
size_t fileSize;
char *fileData = NULL;
char output[250000];

void LoadBmp(const char *fileName)
{

	if (fileData != NULL)
	{
		free(fileData);
		fileData = NULL;
	}

	FILE *file = fopen(fileName, "rb");
	if (file)
	{
		fseek(file, 0, SEEK_END);
		fileSize = ftell(file);
		fseek(file, 0, SEEK_SET);
		fileData = malloc(sizeof(char) * fileSize);
		fread(fileData, sizeof(char), fileSize, file);
	}
	else printf("Error opening the file\n");
	fclose(file);
}

int main( int argc, char *argv[] )
{

    LoadBmp("test.bmp");

    SDL_Surface *imageSurface = NULL;
    SDL_Surface *windowSurface = NULL;

    if ( SDL_Init( SDL_INIT_EVERYTHING ) < 0 )
    {
	    printf("ERROR\n");
    }

    SDL_Window *window = SDL_CreateWindow( "Program", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, WIDTH, HEIGHT, SDL_WINDOW_ALLOW_HIGHDPI );
    windowSurface = SDL_GetWindowSurface( window );

    if ( NULL == window )
    {
	    printf("ERROR\n");

        return EXIT_FAILURE;
    }

    SDL_Event windowEvent;

	SDL_RWops *data = SDL_RWFromMem(fileData, fileSize);
    imageSurface = SDL_LoadBMP_RW(data, 0);

    if( imageSurface == NULL )
    {
	    printf("ERROR\n");
    }

    while ( 1 )
    {
        if ( SDL_PollEvent( &windowEvent ) )
        {
            if (SDL_KEYDOWN == windowEvent.type)
            {
                switch (windowEvent.key.keysym.sym)
                {
                    case SDLK_LEFT:  newContrast = --newContrast < minContrast ? minContrast : newContrast; break;
                    case SDLK_RIGHT: newContrast = ++newContrast > maxContrast ? maxContrast : newContrast; break;
                    case SDLK_UP: wybor = wybor == 0 ? 1 : 0; break;
                }

                printf("     %d ", newContrast);

                func(fileData, output, newContrast, wybor);


                SDL_FillRect(windowSurface, NULL, 0x000000);

                SDL_RWops *data = SDL_RWFromMem(output, 151646);
                printf("TEST %d\n", output);

                /*FILE *file = fopen("test.bmp", "wb");
                printf("BegFile\n");
                fwrite(fileData, sizeof(char), newW*newH*4+138, file);
                printf("EndFile\n");
                fclose(file);
                printf("close file\n");

                printf("TEST3\n");*/

                imageSurface = SDL_LoadBMP_RW(data, 0);
                //printf("test2\n");*/


            }
            else if ( SDL_QUIT == windowEvent.type )
            {
                        break;
                //LoadBmp("dst.bmp");
                //SDL_RWops *data = SDL_RWFromMem(fileData, fileSize);
                    //imageSurface = SDL_LoadBMP_RW(data, 0);

                //




            }
        }

        SDL_BlitSurface( imageSurface, NULL, windowSurface, NULL );

        SDL_UpdateWindowSurface( window );
    }

    SDL_FreeSurface( imageSurface );
    SDL_FreeSurface( windowSurface );

    imageSurface = NULL;
    windowSurface = NULL;

    SDL_DestroyWindow( window );
    SDL_Quit( );

    return EXIT_SUCCESS;
}
