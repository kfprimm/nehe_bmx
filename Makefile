
.PHONY: all *.bmx

ifdef $(WINDIR)
EXT = exe
endif

NAME =	00_template 02_your_first_polygon 03_adding_color 04_rotation 05_3d_shapes 06_texture_mapping \
				07_texture_filters_lighting_keyboard_control 08_blending 09_moving_bitmaps_in_3d_space \
				10_loading_and_moving_through_a_3d_world 11_flag_effect 12_display_lists 17_2d_font \
				18_quadratics 19_particles 20_masking 21_line 22_bumpmapping 23_environment_mapping \
				24_scissoring_tga 25_morphing_points 26_stencil_reflection 27_shadow_casting 28_bezier \
				29_raw_image 30_magic_room 31_model_renderer 32_picking 34_height_map 35_movie_player \
				36_radial_blur 37_cell_shading 38_resource_file 39_physics 40_rope_physics 41_volumetric_fog \
				42_multiple_viewport
			
SRC = $(foreach src, $(NAME), $(src)$(EXT))

all: $(SRC)

%$(EXT): %.bmx framework.bmx object.bmx
	bmk makeapp -r -o $@ $<
	


