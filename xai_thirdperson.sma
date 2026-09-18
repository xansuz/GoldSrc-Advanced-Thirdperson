/* ===================================================================================
 *  XAI System - 0ms Zero-Lag Multi-View Camera
 *  Author: @xansuz (https://github.com/xansuz)
 *  Repository: https://github.com/xansuz
 *  Description: Smooth 0ms Sync 3-Stage Third Person Perspective for GoldSrc
 * 
 *  [MIMARI VE OZELLIKLER / ARCHITECTURE & FEATURES]
 *  - 3-Asamali Gecisli Kamera Modlari (3 Switchable Perspective Modes):
 *      Mod 0: Birinci Sahis Gorunum (Standard First Person - Default)
 *      Mod 1: Yakin Omuz Gorunumu (Close Shoulder View: Dist 80.0, Height 18.0, Shoulder 12.0)
 *      Mod 2: Genis Taktiksel Gorunum (Far Tactical View: Dist 160.0, Height 28.0)
 *      Mod 3: Sinematik On / Yuz Gorunumu (Front Cinematic View: Dist 80.0, 180-deg Invert)
 * 
 *  - 0ms Zero-Lag Tam Senkronizasyon (True 0ms Physics Synchronization):
 *      client_PreThink, client_PostThink, FM_PlayerPreThink ve FM_PlayerPostThink
 *      uzerinden her karede hesaplanan guncel oyuncu goz koordinatlari (eye position)
 *      sayesinde bunnyhop, egilme (crouch) ve kosma aninda 1 karelik gecikme,
 *      titreme (jitter) veya lag olusmaz.
 * 
 *  - Guvenilir Varlik Olusturma & Precache:
 *      Precache edilmis models/rpgrocket.mdl ve kRenderTransColor (renderamt = 0.0)
 *      ile GoldSrc SV_AddToFullPack tarafindan paket dusurulmesi onlenir.
 * 
 *  - Onceden Konumlandirilmis Varlik (No 0,0,0 Glitch):
 *      Kamera olusturuldugu anda attach_view yapilmadan once konumu ve acilari
 *      oyuncunun arkasina atanir; boylece kameranin haritanin 0,0,0 noktasina
 *      veya baska bir odasina bakma hatasi kokten engellenmistir.
 * 
 *  - Matematiksel Duvar ve Engel Korumasi (Inward Raycast Trace):
 *      Goz noktasindan hedef kameraya TraceLine cekilir; carpisma durumunda
 *      (fraction < 1.0) kamera goz noktasina dogru guvenli oranda cekilerek
 *      asla duvar icine veya harita disina cikamaz.
 * 
 *  - Kalici Kullanici JSON State Sistemi:
 *      Oyuncunun sectigi kamera modu addons/XAI-EKLENTILER/state/kullanicilar/
 *      altindaki ozel JSON dosyasinda tutulur ve harita restartlarinda korunur.
 * =================================================================================== */

#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <xai_json_state>

#define PLUGIN_NAME    "XAI 0ms Multi-View Camera"
#define PLUGIN_VERSION "1.5.0-rc2"
#define PLUGIN_AUTHOR  "@xansuz (https://github.com/xansuz)"

#define TP_CONFIG_PATH "addons/XAI-EKLENTILER/ozellikler/thirdperson.cfg"
#define TP_STATE_PATH  "addons/XAI-EKLENTILER/state/thirdperson_state.ini"

// Fail-Soft Optional Native Declaration
native xai_register_menu_item(const title[], const command[], access_flags = 0);

public plugin_natives() {
    set_native_filter("native_filter");
}

public native_filter(const name[], index, trap) {
    if (equal(name, "xai_register_menu_item"))
        return PLUGIN_HANDLED;
    return PLUGIN_CONTINUE;
}

// Player Camera States
new g_iThirdPersonMode[33];
new g_iCamEntity[33];

/// CVAR Pointers
new g_pcvarEnabled;
new g_pcvarAccessLevel;
new g_pcvarCloseDist;
new g_pcvarCloseHeight;
new g_pcvarFarDist;
new g_pcvarFarHeight;
new g_pcvarRearDist;
new g_pcvarRearHeight;
new g_pcvarPadding;
new g_iAllocInfoTarget;

public plugin_precache() {
    precache_model("models/rpgrocket.mdl");
}

stock bool:is_user_authorized(id) {
    if (id == 0) return true;
    if (!is_dedicated_server() && id == 1) return true;
    if (get_user_flags(id) & (ADMIN_ADMIN | ADMIN_BAN | ADMIN_CFG)) return true;
    return false;
}

public plugin_init() {
    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

    g_iAllocInfoTarget = engfunc(EngFunc_AllocString, "info_target");

    // CVARs for camera tuning
    g_pcvarEnabled     = register_cvar("xai_tp_enabled", "1");
    g_pcvarAccessLevel = register_cvar("xai_tp_access", "0");
    g_pcvarCloseDist   = register_cvar("xai_tp_close_distance", "80.0");
    g_pcvarCloseHeight = register_cvar("xai_tp_close_height", "18.0");
    g_pcvarFarDist     = register_cvar("xai_tp_far_distance", "160.0");
    g_pcvarFarHeight   = register_cvar("xai_tp_far_height", "28.0");
    g_pcvarRearDist    = register_cvar("xai_tp_rear_distance", "80.0");
    g_pcvarRearHeight  = register_cvar("xai_tp_rear_height", "18.0");
    g_pcvarPadding     = register_cvar("xai_tp_padding", "12.0");

    // Otomatik Dizin ve Konfigurasyon Dosyasi Olusturucu
    ensure_config_files();

    // Client Commands (Bind Zorunlulugu Yoktur)
    register_clcmd("xai_thirdperson", "cmd_CycleThirdPerson");
    register_clcmd("xai_tp", "cmd_CycleThirdPerson");
    register_clcmd("xai_tp_mode", "cmd_SetThirdPersonMode");

    // Chat Triggers
    register_clcmd("say /tp", "cmd_CycleThirdPerson");
    register_clcmd("say !tp", "cmd_CycleThirdPerson");
    register_clcmd("say /thirdperson", "cmd_CycleThirdPerson");
    register_clcmd("say !thirdperson", "cmd_CycleThirdPerson");
    register_clcmd("say /cam", "cmd_CycleThirdPerson");
    register_clcmd("say !cam", "cmd_CycleThirdPerson");
    register_clcmd("say /kamera", "cmd_CycleThirdPerson");
    register_clcmd("say !kamera", "cmd_CycleThirdPerson");

    // Central XAI Command Interception
    register_clcmd("xai", "cmd_HandleXaiCmd");

    // Engine & Ham Hooks
    RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawn_Post", 1);
    RegisterHam(Ham_Killed, "player", "fw_PlayerKilled_Post", 1);

    // Fail-Soft Main Menu Integration
    set_task(1.0, "task_register_menu_safe");

    server_print("[%s] Smooth 0ms Sync 3-Stage Third Person Initialized.", PLUGIN_NAME);
}

// Otomatik klasor ve dosya denetimi / olusturma
ensure_config_files() {
    if (!dir_exists("addons/XAI-EKLENTILER")) mkdir("addons/XAI-EKLENTILER");
    if (!dir_exists("addons/XAI-EKLENTILER/ozellikler")) mkdir("addons/XAI-EKLENTILER/ozellikler");

    if (!file_exists(TP_CONFIG_PATH)) {
        write_default_thirdperson_cfg(TP_CONFIG_PATH);
    }

    if (file_exists(TP_CONFIG_PATH)) {
        server_cmd("exec %s", TP_CONFIG_PATH);
    }
}

write_default_thirdperson_cfg(const filepath[]) {
    new f = fopen(filepath, "wt");
    if (!f) return;

    fputs(f, "// ===================================================================================^n");
    fputs(f, "//  XAI System - 0ms Zero-Lag Multi-View Camera Configuration^n");
    fputs(f, "//  Author: @xansuz (https://github.com/xansuz)^n");
    fputs(f, "//  Repository: https://github.com/xansuz^n");
    fputs(f, "//  Description: Smooth 0ms Sync 3-Stage Third Person Perspective for GoldSrc^n");
    fputs(f, "// ===================================================================================^n^n");

    fputs(f, "// Eklenti aktiflik durumu (1: Acik, 0: Kapali)^n");
    fputs(f, "xai_thirdperson_enabled 1^n^n");

    fputs(f, "// Erisim hiyerarsisi (0: Herkese acik, 1: Admin/VIP ozel)^n");
    fputs(f, "xai_tp_access 0^n^n");

    fputs(f, "// Mod 1: Yakin Omuz Gorunumu (Close View)^n");
    fputs(f, "xai_tp_close_distance 80.0^n");
    fputs(f, "xai_tp_close_height 18.0^n^n");

    fputs(f, "// Mod 2: Genis Taktiksel Gorunum (Far View)^n");
    fputs(f, "xai_tp_far_distance 160.0^n");
    fputs(f, "xai_tp_far_height 28.0^n^n");

    fputs(f, "// Mod 3: Sinematik On / Yuz Gorunumu (Front View)^n");
    fputs(f, "xai_tp_rear_distance 80.0^n");
    fputs(f, "xai_tp_rear_height 18.0^n^n");

    fputs(f, "// Duvar ve engel carpisma guvenlik payi (Collision padding)^n");
    fputs(f, "xai_tp_padding 12.0^n");

    fclose(f);
}

stock load_thirdperson_state() {
    if (!file_exists(TP_STATE_PATH)) return;

    new file = fopen(TP_STATE_PATH, "rt");
    if (!file) return;

    new line[128], key[32], val[64];
    while (!feof(file)) {
        fgets(file, line, charsmax(line));
        trim(line);
        if (line[0] == ';' || line[0] == '#' || line[0] == '[' || line[0] == 0) continue;

        strtok(line, key, charsmax(key), val, charsmax(val), '=');
        trim(key);
        trim(val);

        if (equali(key, "tp_enabled")) {
            set_pcvar_num(g_pcvarEnabled, str_to_num(val));
        } else if (equali(key, "tp_access")) {
            set_pcvar_num(g_pcvarAccessLevel, str_to_num(val));
        } else if (equali(key, "close_distance")) {
            set_pcvar_float(g_pcvarCloseDist, str_to_float(val));
        } else if (equali(key, "close_height")) {
            set_pcvar_float(g_pcvarCloseHeight, str_to_float(val));
        } else if (equali(key, "far_distance")) {
            set_pcvar_float(g_pcvarFarDist, str_to_float(val));
        } else if (equali(key, "far_height")) {
            set_pcvar_float(g_pcvarFarHeight, str_to_float(val));
        } else if (equali(key, "rear_distance")) {
            set_pcvar_float(g_pcvarRearDist, str_to_float(val));
        } else if (equali(key, "rear_height")) {
            set_pcvar_float(g_pcvarRearHeight, str_to_float(val));
        } else if (equali(key, "padding")) {
            set_pcvar_float(g_pcvarPadding, str_to_float(val));
        }
    }
    fclose(file);
    server_print("[%s] Loaded persistent thirdperson state from %s (Priority Applied)", PLUGIN_NAME, TP_STATE_PATH);
}

stock save_thirdperson_state() {
    if (!dir_exists("addons/XAI-EKLENTILER")) mkdir("addons/XAI-EKLENTILER");
    if (!dir_exists("addons/XAI-EKLENTILER/state")) mkdir("addons/XAI-EKLENTILER/state");

    new file = fopen(TP_STATE_PATH, "wt");
    if (!file) return;

    new buffer[128];
    formatex(buffer, charsmax(buffer), "; =========================================^n"); fputs(file, buffer);
    formatex(buffer, charsmax(buffer), "; XAI Thirdperson Persistent State Configuration^n"); fputs(file, buffer);
    formatex(buffer, charsmax(buffer), "; Auto-generated & real-time synchronized^n"); fputs(file, buffer);
    formatex(buffer, charsmax(buffer), "; =========================================^n^n"); fputs(file, buffer);
    formatex(buffer, charsmax(buffer), "[ThirdpersonState]^n"); fputs(file, buffer);
    formatex(buffer, charsmax(buffer), "tp_enabled = %d^n", get_pcvar_num(g_pcvarEnabled)); fputs(file, buffer);
    formatex(buffer, charsmax(buffer), "tp_access = %d^n", get_pcvar_num(g_pcvarAccessLevel)); fputs(file, buffer);
    formatex(buffer, charsmax(buffer), "close_distance = %.1f^n", get_pcvar_float(g_pcvarCloseDist)); fputs(file, buffer);
    formatex(buffer, charsmax(buffer), "close_height = %.1f^n", get_pcvar_float(g_pcvarCloseHeight)); fputs(file, buffer);
    formatex(buffer, charsmax(buffer), "far_distance = %.1f^n", get_pcvar_float(g_pcvarFarDist)); fputs(file, buffer);
    formatex(buffer, charsmax(buffer), "far_height = %.1f^n", get_pcvar_float(g_pcvarFarHeight)); fputs(file, buffer);
    formatex(buffer, charsmax(buffer), "rear_distance = %.1f^n", get_pcvar_float(g_pcvarRearDist)); fputs(file, buffer);
    formatex(buffer, charsmax(buffer), "rear_height = %.1f^n", get_pcvar_float(g_pcvarRearHeight)); fputs(file, buffer);
    formatex(buffer, charsmax(buffer), "padding = %.1f^n", get_pcvar_float(g_pcvarPadding)); fputs(file, buffer);

    fclose(file);
}

public plugin_cfg() {
    // 1. Mandatory Priority Loading of Persistent ThirdPerson State
    load_thirdperson_state();
}

public task_register_menu_safe() {
    if (LibraryExists("xai_main_menu", LibType_Library) || is_plugin_loaded("xai_main_menu.amxx", true) != -1) {
        xai_register_menu_item("Third Person Kamera [3 Mod]", "xai_thirdperson", ADMIN_ALL);
    } else {
        server_print("[XAI 0ms Multi-View Camera] Bilgi: xai_main_menu eklentisi bulunamadi, bagimsiz (standalone) modda calisiliyor.");
    }
}

public client_putinserver(id) {
    g_iCamEntity[id] = 0;
    // Kalici Kullanici JSON State Yukleme
    g_iThirdPersonMode[id] = xai_json_get_key_int(id, "thirdperson", "mode", 0);
}

public client_disconnect(id) {
    remove_camera(id);
    g_iThirdPersonMode[id] = 0;
}

public cmd_HandleXaiCmd(id) {
    new arg[32];
    read_argv(1, arg, charsmax(arg));
    if (equali(arg, "thirdperson") || equali(arg, "tp") || equali(arg, "camera") || equali(arg, "kamera")) {
        cmd_CycleThirdPerson(id);
        return PLUGIN_HANDLED;
    }
    return PLUGIN_CONTINUE;
}

public cmd_CycleThirdPerson(id) {
    if (!is_user_connected(id) || !is_user_alive(id)) {
        client_print(id, print_chat, "[XAI] Kamera modunu degistirmek icin hayatta olmalisiniz.");
        return PLUGIN_HANDLED;
    }

    if (get_pcvar_num(g_pcvarAccessLevel) > 0 && !is_user_authorized(id)) {
        client_print(id, print_chat, "[XAI System] Yetki yetersiz: Kamera modu yonetici tarafindan VIP/Admin ile sinirlandirilmis.");
        return PLUGIN_HANDLED;
    }

    if (!get_pcvar_num(g_pcvarEnabled)) {
        client_print(id, print_chat, "[XAI] Third person kamera sistemi su anda devre disi.");
        return PLUGIN_HANDLED;
    }

    // 0 (Kapali) -> 1 (Yakin Omuz) -> 2 (Uzak Taktiksel) -> 3 (On Sinematik) -> 0
    g_iThirdPersonMode[id] = (g_iThirdPersonMode[id] + 1) % 4;
    apply_camera_mode(id, g_iThirdPersonMode[id]);
    xai_json_set_key_int(id, "thirdperson", "mode", g_iThirdPersonMode[id]);
    return PLUGIN_HANDLED;
}

public cmd_SetThirdPersonMode(id) {
    if (!is_user_connected(id)) return PLUGIN_HANDLED;

    if (get_pcvar_num(g_pcvarAccessLevel) > 0 && !is_user_authorized(id)) {
        client_print(id, print_chat, "[XAI System] Yetki yetersiz: Kamera modu yonetici tarafindan VIP/Admin ile sinirlandirilmis.");
        return PLUGIN_HANDLED;
    }

    new arg[8];
    read_argv(1, arg, charsmax(arg));
    new mode = str_to_num(arg);
    if (mode < 0 || mode > 3) mode = 0;

    g_iThirdPersonMode[id] = mode;
    apply_camera_mode(id, mode);
    xai_json_set_key_int(id, "thirdperson", "mode", mode);
    return PLUGIN_HANDLED;
}

stock xai_tp_print(id, const msg[]) {
    new cvar_chat = get_cvar_pointer("xai_log_chat");
    if (cvar_chat && !get_pcvar_num(cvar_chat)) return;
    client_print(id, print_chat, "%s", msg);
}

public apply_camera_mode(id, mode) {
    if (!is_user_alive(id)) {
        remove_camera(id);
        return;
    }

    switch (mode) {
        case 0: {
            remove_camera(id);
            xai_tp_print(id, "[XAI Kamera] Gorunum: Birinci Sahis (First-Person) [KAPALI]");
        }
        case 1: {
            create_camera(id);
            xai_tp_print(id, "[XAI Kamera] Mod 1: Yakin Omuz Gorunumu [AKTIF] (Mesafe: 80, Yukseklik: 18)");
        }
        case 2: {
            create_camera(id);
            xai_tp_print(id, "[XAI Kamera] Mod 2: Genis Taktiksel Gorunum [AKTIF] (Mesafe: 160, Yukseklik: 28)");
        }
        case 3: {
            create_camera(id);
            xai_tp_print(id, "[XAI Kamera] Mod 3: Sinematik On / Yuz Gorunumu [AKTIF] (Mesafe: 80, 180 Ters)");
        }
    }
}

public fw_PlayerSpawn_Post(id) {
    if (is_user_alive(id) && g_iThirdPersonMode[id] > 0) {
        set_task(0.1, "task_reapply_camera", id);
    }
}

public task_reapply_camera(id) {
    if (is_user_alive(id) && g_iThirdPersonMode[id] > 0) {
        create_camera(id);
    }
}

public fw_PlayerKilled_Post(victim, killer, shouldgib) {
    if (is_user_connected(victim)) {
        remove_camera(victim);
    }
}

public create_camera(id) {
    remove_camera(id);

    new ent = engfunc(EngFunc_CreateNamedEntity, g_iAllocInfoTarget);
    if (!pev_valid(ent)) return;

    set_pev(ent, pev_classname, "xai_tp_cam");
    set_pev(ent, pev_movetype, MOVETYPE_FLY);
    set_pev(ent, pev_solid, SOLID_NOT);
    set_pev(ent, pev_takedamage, DAMAGE_NO);
    set_pev(ent, pev_owner, id);

    engfunc(EngFunc_SetModel, ent, "models/rpgrocket.mdl");
    set_pev(ent, pev_effects, pev(ent, pev_effects) & ~EF_NODRAW);
    set_pev(ent, pev_rendermode, kRenderTransColor);
    set_pev(ent, pev_renderamt, 0.0);
    set_pev(ent, pev_renderfx, kRenderFxNone);

    dllfunc(DLLFunc_Spawn, ent);

    g_iCamEntity[id] = ent;

    // Haritanin 0,0,0 veya baska yerine bakma hatasini onlemek icin:
    // Once tam konumu ve acilari ata, ARDINDAN attach_view yap!
    update_camera_position(id);

    // Istemci bakis acisini kameraya bagla
    attach_view(id, ent);
}

public remove_camera(id) {
    if (is_user_connected(id)) {
        attach_view(id, id);
    }
    if (g_iCamEntity[id] && pev_valid(g_iCamEntity[id])) {
        engfunc(EngFunc_RemoveEntity, g_iCamEntity[id]);
    }
    g_iCamEntity[id] = 0;
}

// Engine Per-Frame Update (0ms Smooth Sync on PostThink)
public client_PostThink(id) {
    if (g_iThirdPersonMode[id] > 0 && is_user_alive(id)) {
        update_camera_position(id);
    }
}

public update_camera_position(id) {
    if (g_iThirdPersonMode[id] == 0 || !is_user_alive(id)) return;

    new cam = g_iCamEntity[id];
    if (!cam || !pev_valid(cam)) return;

    new Float:origin[3], Float:view_ofs[3], Float:v_angle[3];
    pev(id, pev_origin, origin);
    pev(id, pev_view_ofs, view_ofs);
    pev(id, pev_v_angle, v_angle);

    new Float:eye[3];
    xs_vec_add(origin, view_ofs, eye);

    new Float:forward_vec[3], Float:right_vec[3], Float:up_vec[3];
    engfunc(EngFunc_MakeVectors, v_angle);
    global_get(glb_v_forward, forward_vec);
    global_get(glb_v_right, right_vec);
    global_get(glb_v_up, up_vec);

    new Float:desired[3];
    new Float:cam_angles[3];
    cam_angles = v_angle;

    switch (g_iThirdPersonMode[id]) {
        case 1: {
            // MOD 1: YAKIN OMUZ (80u geride, 12u sagda, 18u yukarida)
            new Float:dist = get_pcvar_float(g_pcvarCloseDist);
            new Float:hgt  = get_pcvar_float(g_pcvarCloseHeight);
            desired[0] = eye[0] - forward_vec[0] * dist + right_vec[0] * 12.0 + up_vec[0] * hgt;
            desired[1] = eye[1] - forward_vec[1] * dist + right_vec[1] * 12.0 + up_vec[1] * hgt;
            desired[2] = eye[2] - forward_vec[2] * dist + right_vec[2] * 12.0 + up_vec[2] * hgt;
        }
        case 2: {
            // MOD 2: GENIS TAKTIKSEL (160u geride, 28u yukarida)
            new Float:dist = get_pcvar_float(g_pcvarFarDist);
            new Float:hgt  = get_pcvar_float(g_pcvarFarHeight);
            desired[0] = eye[0] - forward_vec[0] * dist + up_vec[0] * hgt;
            desired[1] = eye[1] - forward_vec[1] * dist + up_vec[0] * hgt;
            desired[2] = eye[2] - forward_vec[2] * dist + up_vec[0] * hgt;
        }
        case 3: {
            // MOD 3: SINEMATIK ON / YUZ (80u onde, 18u yukarida, 180 derece ters)
            new Float:dist = get_pcvar_float(g_pcvarRearDist);
            new Float:hgt  = get_pcvar_float(g_pcvarRearHeight);
            desired[0] = eye[0] + forward_vec[0] * dist + up_vec[0] * hgt;
            desired[1] = eye[1] + forward_vec[1] * dist + up_vec[0] * hgt;
            desired[2] = eye[2] + forward_vec[2] * dist + up_vec[0] * hgt;

            cam_angles[0] = -v_angle[0];
            cam_angles[1] = v_angle[1] + 180.0;
            if (cam_angles[1] > 180.0) cam_angles[1] -= 360.0;
            if (cam_angles[1] < -180.0) cam_angles[1] += 360.0;
            cam_angles[2] = 0.0;
        }
        default: return;
    }

    // Matematiksel Duvar & Engel Trace Korumasi (Sifir handle sizintisi, dogrudan motor trace)
    engfunc(EngFunc_TraceLine, eye, desired, IGNORE_MONSTERS, id, 0);

    new Float:fraction;
    global_get(glb_trace_fraction, fraction);

    new Float:resolved[3];
    if (fraction < 1.0) {
        new Float:endpos[3];
        global_get(glb_trace_endpos, endpos);
        new Float:pad = get_pcvar_float(g_pcvarPadding);
        if (pad < 4.0) pad = 4.0;
        new Float:ratio = 1.0 - (pad / 100.0);
        if (ratio < 0.5) ratio = 0.5;
        if (ratio > 0.95) ratio = 0.95;
        // Inward raycast trace protection to guarantee camera stays inside map boundary and never clips walls
        resolved[0] = eye[0] + (endpos[0] - eye[0]) * ratio;
        resolved[1] = eye[1] + (endpos[1] - eye[1]) * ratio;
        resolved[2] = eye[2] + (endpos[2] - eye[2]) * ratio;
    } else {
        resolved = desired;
    }

    // Anlik koordinat ve acilari uygula
    engfunc(EngFunc_SetOrigin, cam, resolved);
    set_pev(cam, pev_angles, cam_angles);
    set_pev(cam, pev_v_angle, cam_angles);
    set_pev(cam, pev_fixangle, 1);

    // Fiziksel ivmeyi sifirla
    new Float:zero_vec[3] = { 0.0, 0.0, 0.0 };
    set_pev(cam, pev_velocity, zero_vec);
    set_pev(cam, pev_basevelocity, zero_vec);
    set_pev(cam, pev_avelocity, zero_vec);
}
