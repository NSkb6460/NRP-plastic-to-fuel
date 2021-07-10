function [energy_allocation] = en_all_fuel_TE(Fuelgas,TE)

energyDiesel = 18535;
energyNaphtha =19320*0.21;
energyChar = 1942;
energyFuelgas = Fuelgas*21942-0.13.*TE;
electricity_fuelgas = 0;

energy_allocation = energyDiesel ./ (energyDiesel + energyNaphtha + energyChar + energyFuelgas + electricity_fuelgas);

end