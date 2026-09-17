/* ===================================================================================
 *  XAI System - Advanced 3-Mode Third Person Camera
 *  Author: @xansuz (https://github.com/xansuz)
 *  Repository: https://github.com/xansuz
 *  Description: Enterprise 3-Stage Dynamic Third Person Perspective for GoldSrc
 * =================================================================================== */

#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <xs>

#define PLUGIN_NAME    "XAI Advanced 3-Mode Third Person"
#define PLUGIN_VERSION "2.2.1"
#define PLUGIN_AUTHOR  "@xansuz"
#define PLUGIN_URL     "https://github.com/xansuz"

// Dynamic Menu Hook
#pragma reqlib xai_main_menu
#if !defined AMXMODX_NOAUTOLOAD
    #pragma loadlib xai_main_menu
#endif

native xai_register_menu_item(const title[], const command[], access_flags = 0);

new g_iThirdPersonMode[33];
new g_iCamEntity[33];

// CVAR Pointers
new g_pcvarCloseDist;
new g_pcvarCloseHeight;
new g_pcvarFarDist;
new g_pcvarFarHeight;
new g_pcvarRearDist;
new g_pcvarRearHeight;
new g_pcvarPadding;

public plugin_init() {
    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

    // CVAR Ayarlari
    g_pcvarCloseDist   = register_cvar("xai_tp_close_distance", "88.0");
    g_pcvarCloseHeight = register_cvar("xai_tp_close_height", "24.0");
    g_pcvarFarDist     = register_cvar("xai_tp_far_distance", "176.0");
    g_pcvarFarHeight   = register_cvar("xai_tp_far_height", "36.0");
    g_pcvarRearDist    = register_cvar("xai_tp_rear_distance", "88.0");
    g_pcvarRearHeight  = register_cvar("xai_tp_rear_height", "24.0");
    g_pcvarPadding     = register_cvar("xai_tp_padding", "12.0");

    // Otomatik config yukleme
    server_cmd("exec addons/XAI-EKLENTISI/ozellikler/thirdperson.cfg");

    // Komutlar
    register_clcmd("xai_thirdperson", "cmd_CycleThirdPerson");
    register_clcmd("xai", "cmd_HandleXaiCmd");
    register_clcmd("xai_tp_mode", "cmd_SetThirdPersonMode");
    register_clcmd("say /tp", "cmd_CycleThirdPerson");
    register_clcmd("say !tp", "cmd_CycleThirdPerson");
    register_clcmd("say /thirdperson", "cmd_CycleThirdPerson");
    register_clcmd("say_team /tp", "cmd_CycleThirdPerson");

    // Eventler
    register_event("ResetHUD", "event_PlayerSpawn", "be");
    register_event("DeathMsg", "event_PlayerDeath", "a");

    // Menu entegrasyon gorevi
    set_task(1.2, "task_RegisterMenuIntegration");

    server_print("[%s] Enterprise v%s by %s Ready.", PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
}

public plugin_natives() {
    set_native_filter("native_filter");
}

public native_filter(const name[], index, trap) {
    if (!trap) return PLUGIN_HANDLED;
    return PLUGIN_CONTINUE;
}

public task_RegisterMenuIntegration() {
    if (LibraryExists("xai_main_menu", LibType_Library) || is_plugin_loaded("xai_main_menu.amxx") != -1 || module_exists("xai_main_menu")) {
        xai_register_menu_item("Third Person Kamera [F1 / 3 Mod]", "xai_thirdperson", ADMIN_ALL);
        server_print("[XAI-TP] Main menu entegrasyonu saglandi.");
    } else {
        server_print("[XAI-TP] Bagimsiz modda calisiyor (xai_main_menu yok).");
    }
}

public client_putinserver(id) {
    g_iThirdPersonMode[id] = 0;
    g_iCamEntity[id] = 0;

    // Konsol bilgilendirmesi
    set_task(3.0, "task_PrintConsoleNotice", id);
}

public task_PrintConsoleNotice(id) {
    if (!is_user_connected(id)) return;

    console_print(id, "============================================================");
    console_print(id, " [XAI CAMERA] 3 Kademeli Kamera Sistemi Aktif! (By %s)", PLUGIN_AUTHOR);
    console_print(id, " [REHBER] Modlar: 1. Sahis -> Omuz -> Taktiksel -> Sinematik On");
    console_print(id, " [KOMUT] Chat: /tp veya Konsol: xai_thirdperson");
    console_print(id, " [TAVSIYE] F1 tusuna atamak icin: bind F1 xai_thirdperson");
    console_print(id, "============================================================");

    client_print(id, print_chat, "[XAI] Kamera modlari arasinda gecis icin /tp yaz! Tus atamasi rehberi konsolda.");
}

public client_disconnect(id) {
    remove_camera(id);
    g_iThirdPersonMode[id] = 0;
}

public cmd_HandleXaiCmd(id) {
    new arg[32];
    read_argv(1, arg, charsmax(arg));

    if (equali(arg, "thirdperson") || equali(arg, "tp")) {
        cmd_CycleThirdPerson(id);
        return PLUGIN_HANDLED;
    }
    return PLUGIN_CONTINUE;
}

public cmd_CycleThirdPerson(id) {
    if (!is_user_connected(id) || !is_user_alive(id)) 
        return PLUGIN_HANDLED;

    g_iThirdPersonMode[id] = (g_iThirdPersonMode[id] + 1) % 4;
    apply_camera_mode(id, g_iThirdPersonMode[id]);
    return PLUGIN_HANDLED;
}

public cmd_SetThirdPersonMode(id) {
    if (!is_user_connected(id)) 
        return PLUGIN_HANDLED;

    new arg[8];
    read_argv(1, arg, charsmax(arg));
    new mode = str_to_num(arg);

    if (mode < 0 || mode > 3) mode = 0;

    g_iThirdPersonMode[id] = mode;
    apply_camera_mode(id, mode);
    return PLUGIN_HANDLED;
}

public apply_camera_mode(id, mode) {
    if (!is_user_alive(id)) {
        remove_camera(id);
        return;
    }

    switch (mode) {
        case 0: {
            remove_camera(id);
            client_print(id, print_chat, "[XAI Kamera] Gorunum: Birinci Sahis [KAPALI]");
        }
        case 1: {
            create_camera(id);
            client_print(id, print_chat, "[XAI Kamera] Mod 1: Yakin Omuz Gorunumu [AKTIF] (Mesafe: 88, Yukseklik: 24)");
        }
        case 2: {
            create_camera(id);
            client_print(id, print_chat, "[XAI Kamera] Mod 2: Genis Taktiksel Gorunum [AKTIF] (Mesafe: 176, Yukseklik: 36)");
        }
        case 3: {
            create_camera(id);
            client_print(id, print_chat, "[XAI Kamera] Mod 3: Sinematik On/Yuz Gorunumu [AKTIF] (Mesafe: 88, Aci: 180 Ters)");
        }
    }
}

public event_PlayerSpawn(id) {
    if (g_iThirdPersonMode[id] > 0) {
        set_task(0.2, "task_ReapplyCamera", id);
    }
}

public task_ReapplyCamera(id) {
    if (is_user_alive(id) && g_iThirdPersonMode[id] > 0) {
        create_camera(id);
    }
}

public event_PlayerDeath() {
    new victim = read_data(2);
    if (victim > 0 && victim <= 32) {
        remove_camera(victim);
    }
}

public create_camera(id) {
    remove_camera(id);

    new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));
    if (!pev_valid(ent)) return;

    set_pev(ent, pev_classname, "xai_tp_cam");
    set_pev(ent, pev_movetype, MOVETYPE_NONE);
    set_pev(ent, pev_solid, SOLID_NOT);
    set_pev(ent, pev_owner, id);

    new player_model[64];
    pev(id, pev_model, player_model, charsmax(player_model));
    if (player_model[0]) {
        engfunc(EngFunc_SetModel, ent, player_model);
        set_pev(ent, pev_sequence, pev(id, pev_sequence));
    }

    set_pev(ent, pev_effects, pev(ent, pev_effects) | EF_NODRAW);
    set_pev(ent, pev_rendermode, kRenderTransAlpha);
    set_pev(ent, pev_renderamt, 0.0);

    g_iCamEntity[id] = ent;
    attach_view(id, ent);
}

public remove_camera(id) {
    if (g_iCamEntity[id] && pev_valid(g_iCamEntity[id])) {
        attach_view(id, id);
        engfunc(EngFunc_RemoveEntity, g_iCamEntity[id]);
        g_iCamEntity[id] = 0;
    }
}

public client_PreThink(id) {
    if (!g_iThirdPersonMode[id] || !is_user_alive(id)) 
        return;

    new cam = g_iCamEntity[id];
    if (!cam || !pev_valid(cam)) 
        return;

    new Float:origin[3], Float:view_ofs[3], Float:v_angle[3];
    pev(id, pev_origin, origin);
    pev(id, pev_view_ofs, view_ofs);
    pev(id, pev_v_angle, v_angle);

    new Float:eye[3];
    xs_vec_add(origin, view_ofs, eye);

    new Float:forward_vec[3], Float:right_vec[3], Float:up_vec[3];
    engfunc(EngFunc_AngleVectors, v_angle, forward_vec, right_vec, up_vec);

    new Float:distance = 88.0;
    new Float:height = 24.0;
    new Float:cam_dir[3];
    new Float:cam_angles[3];
    cam_angles = v_angle;

    switch (g_iThirdPersonMode[id]) {
        case 1: {
            distance = get_pcvar_float(g_pcvarCloseDist);
            height = get_pcvar_float(g_pcvarCloseHeight);
            xs_vec_neg(forward_vec, cam_dir);
        }
        case 2: {
            distance = get_pcvar_float(g_pcvarFarDist);
            height = get_pcvar_float(g_pcvarFarHeight);
            xs_vec_neg(forward_vec, cam_dir);
        }
        case 3: {
            distance = get_pcvar_float(g_pcvarRearDist);
            height = get_pcvar_float(g_pcvarRearHeight);
            cam_dir = forward_vec;
            
            cam_angles[1] += 180.0;
            if (cam_angles[1] > 180.0) {
                cam_angles[1] -= 360.0;
            }
            cam_angles[0] = -cam_angles[0];
        }
    }

    if (distance < 40.0) distance = 40.0;
    if (distance > 320.0) distance = 320.0;
    if (height < -24.0) height = -24.0;
    if (height > 96.0) height = 96.0;

    new Float:desired[3];
    desired[0] = eye[0] + (cam_dir[0] * distance);
    desired[1] = eye[1] + (cam_dir[1] * distance);
    desired[2] = eye[2] + (cam_dir[2] * distance) + height;

    new tr = create_tr2();
    engfunc(EngFunc_TraceLine, eye, desired, DONT_IGNORE_MONSTERS, id, tr);

    new Float:fraction;
    get_tr2(tr, TR_flFraction, fraction);

    new Float:resolved[3];
    if (fraction < 1.0) {
        new Float:endpos[3];
        get_tr2(tr, TR_vecEndPos, endpos);

        new Float:padding = get_pcvar_float(g_pcvarPadding);
        if (padding < 2.0) padding = 2.0;
        if (padding > 32.0) padding = 32.0;

        resolved[0] = endpos[0] - (cam_dir[0] * padding);
        resolved[1] = endpos[1] - (cam_dir[1] * padding);
        resolved[2] = endpos[2] - (cam_dir[2] * padding);
    } else {
        resolved = desired;
    }
    free_tr2(tr);

    engfunc(EngFunc_SetOrigin, cam, resolved);
    set_pev(cam, pev_angles, cam_angles);
    set_pev(cam, pev_v_angle, cam_angles);

    new Float:zero_vec[3] = {0.0, 0.0, 0.0};
    set_pev(cam, pev_velocity, zero_vec);

    attach_view(id, cam);
}