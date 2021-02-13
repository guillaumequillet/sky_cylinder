require 'gosu'
require 'opengl'
require 'glu'
require_relative './texture.rb'
require_relative './sky_cylinder.rb'

OpenGL.load_lib
GLU.load_lib

include OpenGL, GLU

class Window < Gosu::Window
    def initialize
        super(256 * 2, 224 * 2, false)
    end

    def button_down(id)
        super
        close! if id == Gosu::KB_ESCAPE
    end

    def update
        @map_width ||= 40
        @map_length ||= 40

        @cam_t_x ||= @map_width * 0.5 * 16
        @cam_t_y ||= 32
        @cam_t_z ||= @map_length * 0.5 * 16
        @cam_angle ||= 0
        @cam_distance = 16.0

        vel = 1
        if Gosu::button_down?(Gosu::KB_UP)
            @cam_t_x += vel * Math::cos(@cam_angle * Math::PI / 180.0) 
            @cam_t_z += vel * Math::sin(@cam_angle * Math::PI / 180.0) 
        elsif Gosu::button_down?(Gosu::KB_DOWN)
            @cam_t_x -= vel * Math::cos(@cam_angle * Math::PI / 180.0) 
            @cam_t_z -= vel * Math::sin(@cam_angle * Math::PI / 180.0) 
        end

        @cam_angle += vel if Gosu::button_down?(Gosu::KB_RIGHT)
        @cam_angle -= vel if Gosu::button_down?(Gosu::KB_LEFT)

        @cam_x = @cam_t_x - @cam_distance * Math::cos(@cam_angle * Math::PI / 180)
        @cam_y = @cam_t_y
        @cam_z = @cam_t_z - @cam_distance * Math::sin(@cam_angle * Math::PI / 180)
    end

    def draw
        gl do
            glEnable(GL_DEPTH_TEST)
            glEnable(GL_TEXTURE_2D)
            glMatrixMode(GL_PROJECTION)
            glLoadIdentity
            gluPerspective(60, self.width.to_f / self.height, 0.1, 1000)
            glMatrixMode(GL_MODELVIEW)
            glLoadIdentity
            gluLookAt(@cam_x, @cam_y, @cam_z,  @cam_t_x, @cam_t_y, @cam_t_z,  0, 1, 0)

            @sky_cylinder ||= SkyCylinder.new('./gfx/skies/sky1.png', 16, 3)
            @sky_cylinder.draw(@cam_t_x, 0, @cam_t_z)

            @grass ||= Texture.new('./gfx/temp.png')

            w = @map_width
            h = @map_length
            glBindTexture(GL_TEXTURE_2D, @grass.get_id)
            glPushMatrix
                glScalef(@grass.width, 1, @grass.height)
                glBegin(GL_QUADS)
                    glTexCoord2d(0, h); glVertex3f(0, 0, 0)
                    glTexCoord2d(0, 0); glVertex3f(0, 0, h)
                    glTexCoord2d(w, 0); glVertex3f(w, 0, h)
                    glTexCoord2d(w, h); glVertex3f(w, 0, 0)
                glEnd
            glPopMatrix
        end

        @font ||= Gosu::Font.new(24)
        @font.draw_text("FPS : #{Gosu::fps}", 10, 10, 0)
    end
end

Window.new.show