#ifndef LIBSM64GD_SM64MARIOINTERNAL_H
#define LIBSM64GD_SM64MARIOINTERNAL_H

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/ref_counted.hpp>

#include <sm64_surface_properties.hpp>
#include <sm64_mario_geometry.hpp>

extern "C"
{
#include <libsm64.h>
}

#ifdef WIN32
#include <windows.h>
#endif

class SM64MarioInternal : public godot::RefCounted
{
    GDCLASS(SM64MarioInternal, godot::RefCounted);

public:
    SM64MarioInternal() = default;

    int mario_create(godot::Vector3 p_position, godot::Vector3 p_rotation);

    /**
     * @brief Tick Mario with the provided ID
     *
     * @param mario_id Ticked Mario's ID.
     * @param input Mario's inputs. format:
     * {
     *     "cam_look": godot::Vector2 (Camera's X and Z coordinates in Godot),
     *     "stick":    godot::Vector2,
     *     "a":        bool,
     *     "b":        bool,
     *     "z":        bool,
     * }
     * @return godot::Dictionary Mario's state and MeshArray. format:
     * {
     *     "position": godot::Vector3,
     *     "velocity": godot::Vector3,
     *     "face_angle": real_t,
     *     "health": int,
     *     "array_mesh": godot::Ref<godot::ArrayMesh>,
     * }
     */
    godot::Dictionary tick(godot::Dictionary p_input);

    void mario_delete();

    void set_action(int p_action);
    void set_state(int p_flags);
    void set_position(godot::Vector3 p_position);
    void set_angle(real_t p_face_angle);
    void set_velocity(godot::Vector3 p_velocity);
    void set_forward_velocity(real_t p_velocity);
    void set_invincibility(int p_timer);
    void set_water_level(real_t p_level);
    void set_floor_override(godot::Ref<SM64SurfaceProperties> p_surface_properties);
    void reset_floor_override();
    void set_health(int p_health);
    void take_damage(int p_damage, godot::Vector3 p_source_position, bool p_big_knockback = false);
    void heal(int p_heal_counter);
    void set_lives(int p_lives);
    void interact_cap(int p_cap, int p_cap_time = 0, bool p_play_music = 1);
    void extend_cap(int p_cap_time);
    // bool sm64_mario_attack(int32_t marioId, float x, float y, float z, float hitboxHeight);

protected:
    static void _bind_methods();

private:
    int m_id = -1;

    SM64MarioGeometry m_geometry;

    godot::PackedVector3Array m_position;
    godot::PackedVector3Array m_normal;
    godot::PackedColorArray m_color;
    godot::PackedVector2Array m_uv;
};

#endif // LIBSM64GD_SM64MARIOINTERNAL_H