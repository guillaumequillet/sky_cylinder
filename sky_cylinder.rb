class SkyCylinder
    def initialize(filename, segments = 8, repeat_x = 1)
        @segments = segments
        generate_texture(filename, repeat_x)
        calculate_parameters
        generate_display_list
    end

    def generate_texture(filename, repeat_x)
        # 1 - we load classic Gosu image
        # 2 - Gosu::render will allow us to draw reverted Gosu image on Y axis and repeat_x times repeated on X axis
        gosu_image = Gosu::Image.new(filename, retro: true)
        wip_gosu_texture = Gosu::render(gosu_image.width * repeat_x, gosu_image.height, retro: true) do
            repeat_x.times do |x|
                gosu_image.draw(x * gosu_image.width, gosu_image.height, 0, 1, -1)
            end
        end

        # we use the resulted Gosu image to create an opengl texture 
        @texture = Texture.new(wip_gosu_texture)

        gosu_image = nil
        wip_gosu_texture = nil
    end

    def generate_display_list
        @display_list = glGenLists(1)
        glNewList(@display_list, GL_COMPILE)
            glDisable(GL_DEPTH_TEST)
            glDepthMask(GL_FALSE)
            glEnable(GL_CULL_FACE)
            glCullFace(GL_BACK)
            glBindTexture(GL_TEXTURE_2D, @texture.get_id)
            glBegin(GL_QUADS)
                @segments.times do |segment|
                    x1 = Gosu::offset_x(segment * @segment_angle, @ray_length)
                    z1 = Gosu::offset_y(segment * @segment_angle, @ray_length)
                    x2 = Gosu::offset_x((segment + 1) * @segment_angle, @ray_length)
                    z2 = Gosu::offset_y((segment + 1) * @segment_angle, @ray_length)
                    l = @texture_slice * segment
                    r = @texture_slice * (segment + 1)
                    t = 1
                    b = 0
                    glTexCoord2d(l, t); glVertex3f(x1, @height, z1)
                    glTexCoord2d(l, b); glVertex3f(x1, 0, z1)
                    glTexCoord2d(r, b); glVertex3f(x2, 0, z2)
                    glTexCoord2d(r, t); glVertex3f(x2, @height, z2)
                end
            glEnd
            glEnable(GL_DEPTH_TEST)
            glDepthMask(GL_TRUE)
            glDisable(GL_CULL_FACE)
        glEndList
    end

    def calculate_parameters
        @segment_angle = 360.0 / @segments
        @texture_slice = 1.0 / @segments
        @ray_length = (@texture.width / Math::PI) * 0.5
        @height = @texture.height
    end

    def draw(origin_x = 0, origin_y = 0, origin_z = 0)
        glPushMatrix
            glTranslatef(origin_x, origin_y, origin_z)
            glCallList(@display_list)
        glPopMatrix
    end
end
