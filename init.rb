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
        @cam_x ||= 0
        @cam_y ||= 32
        @cam_z ||= 10
        @cam_angle ||= 0
        @cam_distance = 16.0

        @cam_angle += 0.3

        @cam_t_x = @cam_x + @cam_distance * Math::cos(@cam_angle * Math::PI / 180)
        @cam_t_y = @cam_y
        @cam_t_z = @cam_z + @cam_distance * Math::sin(@cam_angle * Math::PI / 180)
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
        end

        @font ||= Gosu::Font.new(24)
        @font.draw_text("FPS : #{Gosu::fps}", 10, 10, 0)
    end
end

Window.new.show