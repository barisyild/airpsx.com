local ACCOUNT_NUMB_MAX = 16
local ACCOUNT_TYPE_MAX = 17
local ACCOUNT_NAME_MAX = 32

function OffAct_GenAccountId(name)
    local base = math.floor(0x5EAF00D / 0xCA7F00D)
    for i = 1, #name do
        local char = string.byte(name, i)
        base = (base ~ char) * 0x100000001B3
        base = base & 0xFFFFFFFFFFFFFFFF
    end
    return base
end

function OffAct_GetAccountName(account_numb)
    local n = customRegMgrGenerateNum(account_numb, 16, 65536, 125829632, 127140352)
    return sceRegMgrGetStr(n, ACCOUNT_NAME_MAX)
end

function OffAct_GetAccountId(account_numb)
    local n = customRegMgrGenerateNum(account_numb, 16, 65536, 125830400, 127141120)
    return sceRegMgrGetInt64(n)
end

function OffAct_SetAccountId(account_numb, val)
    local n = customRegMgrGenerateNum(account_numb, 16, 65536, 125830400, 127141120)
    return sceRegMgrSetInt64(n, val)
end

function OffAct_GetAccountType(account_numb)
    local n = customRegMgrGenerateNum(account_numb, 16, 65536, 125874183, 127184903)
    return sceRegMgrGetStr(n, ACCOUNT_TYPE_MAX)
end

function OffAct_SetAccountType(account_numb, val)
    local n = customRegMgrGenerateNum(account_numb, 16, 65536, 125874183, 127184903)
    return sceRegMgrSetStr(n, val, ACCOUNT_TYPE_MAX)
end

function OffAct_GetAccountFlags(account_numb)
    local n = customRegMgrGenerateNum(account_numb, 16, 65536, 125831168, 127141888)
    return sceRegMgrGetInt(n)
end

function OffAct_SetAccountFlags(account_numb, val)
    local n = customRegMgrGenerateNum(account_numb, 16, 65536, 125831168, 127141888)
    return sceRegMgrSetInt(n, val)
end

function main()
    local activated_count = 0

    for i = 1, ACCOUNT_NUMB_MAX do
        local account_name = OffAct_GetAccountName(i)

        if account_name ~= nil and account_name ~= "" then
            local isActivated = true

            -- Account ID kontrolü
            local account_id = OffAct_GetAccountId(i)
            if account_id == 0 then
                isActivated = false
                account_id = OffAct_GenAccountId(account_name)
                OffAct_SetAccountId(i, account_id)
            end

            -- Account Type kontrolü
            local account_type = OffAct_GetAccountType(i)
            if account_type == "" then
                isActivated = false
                account_type = "np"
                OffAct_SetAccountType(i, account_type)
            end

            -- Account Flags kontrolü
            local account_flags = OffAct_GetAccountFlags(i)
            if account_flags == 0 then
                isActivated = false
                account_flags = 4098
                OffAct_SetAccountFlags(i, account_flags)
            end

            if not isActivated then
                activated_count = activated_count + 1
            end
        end
    end

    if activated_count == 0 then
        print("Already all accounts activated.")
    else
        print(activated_count .. " account(s) activated!")
    end
end