--
-- Q2Admin example configuration
-- 
-- rename to "config.lua" and place this to quake 2 root
--
-- "--" are commented lines
--

plugins = {
    lrcon = {
        quit_on_empty = true,
        cvars = {
            -- server
            'password', 'maxclients', 'timelimit', 'dmflags', 'sv_gravity', 'sv_iplimit', 'fraglimit',
            'sv_anticheat_required',

            -- mod
            'teamplay', 'ctf', 'matchmode', 'roundtimelimit', 'tgren', 'limchasecam', 'forcedteamtalk',
            'mm_forceteamtalk', 'ir', 'wp_flags', 'itm_flags', 'hc_single', 'use_punch',  'darkmatch',
            'allitem', 'allweapon', 'use_3teams'
        }
    },
    mvd = {
        --mvd_webby = 'http://mvd2.quadaver.org',
        --exec_script_on_system_after_recording = '/home/gameservers/quake2/plugins/mvd_transfer.sh',
        --exec_script_cvars_as_parameters = {"q2a_mvd_file", "game", "hostname"},
        --needs_cvar_q2a_mvd_autorecord = false
    }

}
