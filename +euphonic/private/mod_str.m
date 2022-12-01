function mods_kw = mod_str(req_mods)
    mods_kw = {};
    for ii = 1:2:numel(req_mods)
        mods_kw = [mods_kw { ['"' req_mods{ii} '>=' req_mods{ii+1} '"'] }];
    end
end
