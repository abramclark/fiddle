/* Simple Allegro 5 draw shapes 
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "allegro5/allegro.h"
#include "allegro5/allegro_image.h"
#include "allegro5/allegro_primitives.h"
#include "allegro5/allegro_font.h"

ALLEGRO_DISPLAY *display; // Our window.
int mouse; // Keep track of pressed mouse button.
float zoom = 1.0, rotate;
float scroll_x = 0, scroll_y = 0;

void draw(void) {
    int x, y;
    ALLEGRO_TRANSFORM transform;
    float w, h;
    
    w = al_get_display_width(display);
    h = al_get_display_height(display);
    
    /* Initialize transformation. */
    al_identity_transform(&transform);
    /* Move to scroll position. */
    al_translate_transform(&transform, -scroll_x, -scroll_y);
    /* Rotate and scale around the center first. */
    al_rotate_transform(&transform, rotate);
    al_scale_transform(&transform, zoom, zoom);
    /* Move scroll position to screen center. */
    al_translate_transform(&transform, w * 0.5, h * 0.5);
    /* All subsequent drawing is transformed. */
    al_use_transform(&transform);

    ALLEGRO_COLOR grey = al_map_rgb(200, 200, 200);
    ALLEGRO_COLOR yellow = al_map_rgb(255, 255, 0);
    ALLEGRO_COLOR red = al_map_rgb(255, 0, 0);

    al_clear_to_color(al_map_rgb(0, 0, 0));

    al_draw_filled_rectangle(-100, -100, 200, 200, grey);
    al_draw_filled_circle(0, 0, 100, yellow);
    al_draw_filled_triangle(100, 0, 150, -150, 200, 0, red);
    
    al_identity_transform(&transform);
    al_use_transform(&transform);

    al_flip_display();
}

int main(void) {
    ALLEGRO_TIMER *timer;
    ALLEGRO_EVENT_QUEUE *queue;
    bool redraw = true;
    
    /* Init Allegro 5 + addons. */
    al_init();
    al_init_image_addon();
    al_init_primitives_addon();
    al_init_font_addon();
    al_install_mouse();
    al_install_keyboard();

    /* Create our window. */
    al_set_new_display_flags(ALLEGRO_RESIZABLE);
    display = al_create_display(800, 600);
    al_set_window_title(display, "Allegro draw example");


    queue = al_create_event_queue();
    timer = al_create_timer(1.0 / 60);
    al_register_event_source(queue, al_get_keyboard_event_source());
    al_register_event_source(queue, al_get_mouse_event_source());
    al_register_event_source(queue, al_get_display_event_source(display));
    al_register_event_source(queue, al_get_timer_event_source(timer));
    al_start_timer(timer);

    while (1) {
        ALLEGRO_EVENT event;
        al_wait_for_event(queue, &event);

        if (event.type == ALLEGRO_EVENT_DISPLAY_CLOSE)
            break;
        if (event.type == ALLEGRO_EVENT_KEY_DOWN) {
            if (event.keyboard.keycode == ALLEGRO_KEY_ESCAPE)
                break;
        }
        if (event.type == ALLEGRO_EVENT_MOUSE_BUTTON_DOWN) {
            mouse = event.mouse.button;
        }
        if (event.type == ALLEGRO_EVENT_MOUSE_BUTTON_UP) {
            mouse = 0;
        }
        if (event.type == ALLEGRO_EVENT_MOUSE_AXES) {
            /* Left button scrolls. */
            if (mouse == 1) {
                float x = event.mouse.dx / zoom;
                float y = event.mouse.dy / zoom;
                scroll_x -= x * cos(rotate) + y * sin(rotate);
                scroll_y -= y * cos(rotate) - x * sin(rotate);
            }
            /* Right button zooms/rotates. */
            if (mouse == 2) {
                rotate += event.mouse.dx * 0.01;
                zoom += event.mouse.dy * 0.01 * zoom;
            }
            zoom += event.mouse.dz * 0.1 * zoom;
            if (zoom < 0.1) zoom = 0.1;
            if (zoom > 10) zoom = 10;
        }
        if (event.type == ALLEGRO_EVENT_TIMER)
            redraw = true;
        if (event.type == ALLEGRO_EVENT_DISPLAY_RESIZE) {
            al_acknowledge_resize(display);
            redraw = true;
        }

        if (redraw && al_is_event_queue_empty(queue)) {
            redraw = false;
            draw();
        }
    }
    return 0;
}
