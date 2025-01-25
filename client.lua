local pedCoords1 = vector3(995.2665, -1489.0857, 31.5012)
local pedHeading1 = 95.000
local pedModel1 = `s_m_m_autoshop_02`

local function loadModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end
end

local function hasFakePlateItem()
    return exports.ox_inventory:Search('count', 'pustatablica') > 0
end

local function generateRandomPlate()
    local plate = ''
    for i = 1, 3 do
        plate = plate .. string.char(math.random(65, 90))
    end
    for i = 1, 4 do
        plate = plate .. string.char(math.random(48, 57))
    end
    return plate
end

local function isPlayerAtRearOfVehicle(vehicle)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local vehicleRearCoords = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, -2.5, 0.0)
    local distance = #(playerCoords - vehicleRearCoords)
    return distance < 1.0
end

CreateThread(function()
    loadModel(pedModel1)
    if not HasModelLoaded(pedModel1) then return end

    local ped1 = CreatePed(4, pedModel1, pedCoords1.x, pedCoords1.y, pedCoords1.z - 1.0, pedHeading1, false, true)
    FreezeEntityPosition(ped1, true)
    SetEntityInvincible(ped1, true)
    SetBlockingOfNonTemporaryEvents(ped1, true)

    exports.ox_target:addLocalEntity(ped1, {
        {
            name = 'fakeplate_menu',
            icon = 'fa-solid fa-car',
            label = 'Kup Sfałszowaną Tablicę',
            distance = 1.5,
            onSelect = function()
                lib.registerContext({
                    id = 'fakeplate_shop',
                    title = 'Sklep z Tablicami',
                    options = {
                        {
                            title = 'Sfałszowana Tablica',
                            description = 'Cena: $1000',
                            icon = 'fa-solid fa-money-bill',
                            onSelect = function()
                                TriggerServerEvent('fakeplate:buyPlate')
                            end,
                        }
                    }
                })
                lib.showContext('fakeplate_shop')
            end
        }
    })
end)

exports['qtarget']:Vehicle({
    options = {
        {
            event = 'fakeplate:changePlate',
            label = 'Podmień Tablicę',
            icon = 'fa-solid fa-exchange-alt',
            canInteract = function(entity)
                return hasFakePlateItem() and isPlayerAtRearOfVehicle(entity)
            end,
        },
    },
    distance = 1.0
})

RegisterNetEvent('fakeplate:changePlate', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local vehicle = GetClosestVehicle(playerCoords.x, playerCoords.y, playerCoords.z, 5.0, 0, 71)

    if not vehicle then
        lib.notify({ title = 'Błąd', description = 'Brak pojazdu w pobliżu!', type = 'error' })
        return
    end

    if not hasFakePlateItem() then
        lib.notify({ title = 'Błąd', description = 'Nie masz sfałszowanej tablicy!', type = 'error' })
        return
    end

    if not isPlayerAtRearOfVehicle(vehicle) then
        lib.notify({ title = 'Błąd', description = 'Musisz stać z tyłu pojazdu!', type = 'error' })
        return
    end

    local newPlate = generateRandomPlate()

    if lib.progressBar({
        duration = 20000,
        label = 'Podmiana tablicy...',
        useWhileDead = false,
        canCancel = true,
        anim = { dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', clip = 'machinic_loop_mechandplayer', flag = 1 },
        prop = { model = `prop_tool_screwdvr02`, pos = vec3(0.15, 0.0, 0.01), rot = vec3(90.0, 0.0, 0.0) },
        disable = { move = true, car = true, combat = true },
    }) then
        SetVehicleNumberPlateText(vehicle, newPlate)
        TriggerServerEvent('fakeplate:removePlate')
        lib.notify({ title = 'Sukces', description = 'Sfałszowana tablica została pomyślnie podmieniona na wybranym pojeździe.', type = 'success' })
    else
        print('Anulowano podmianę tablicy')
    end
end)