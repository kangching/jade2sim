if show_energy_plots==1
%     tic
    disp(['Plotting results...']);
    P_Electrical_Sources = P_Electrical_Sources/3600/1000; %[kWh]
    P_Electrical_Storage = P_Electrical_Storage/3600/1000; %[kWh]
    P_Electrical_Regeneration = P_Electrical_Regeneration/3600/1000; %[kWh]
    P_Photovoltaic = P_Photovoltaic/3600/1000; %[kWh]
    P_Charger = P_Charger/3600/1000; %[kWh]
    P_Recovered_Kinetic = P_Recovered_Kinetic/3600/1000; %[kWh]
    P_Electrical_Subsystems = P_Electrical_Subsystems/3600/1000; %[kWh]
    P_Electrical_Component_Loss = P_Electrical_Component_Loss/3600/1000; %[kWh]
    P_Mechanical_Component_Loss = P_Mechanical_Component_Loss/3600/1000; %[kWh]
    P_Mechanical_Braking = P_Mechanical_Braking/3600/1000; %[kWh]
    P_Driving = P_Driving/3600/1000; %[kWh]
    P_Vehicle_Friction = P_Vehicle_Friction/3600/1000; %[kWh]
    P_Cap_Loss = P_Cap_Loss/3600/1000; %[kWh]
    P_DCDC_Loss = P_DCDC_Loss/3600/1000; %[kWh]
    P_Motor_Loss = P_Motor_Loss/3600/1000; %[kWh]
    P_Battery_Loss = P_Battery_Loss/3600/1000; %[kWh]
    

%     while (P_Electrical_Storage+P_Electrical_Regeneration+P_Photovoltaic+ ... 
%             P_Charger+P_Recovered_Kinetic)<10
%         P_Electrical_Storage = P_Electrical_Storage*10;
%         P_Electrical_Regeneration = P_Electrical_Regeneration*10;
%         P_Photovoltaic = P_Photovoltaic*10;
%         P_Charger = P_Charger*10;
%         P_Recovered_Kinetic = P_Recovered_Kinetic*10;
%     end
%     X = [P_Photovoltaic,P_Charger,P_Recovered_Kinetic,P_Electrical_Storage, ... 
%         P_Electrical_Regeneration];
%     explode = [1 1 1 1 1];    
%     labels = {'PV','Charger','Recovered/Kinetic', ... 
%         'Electrical/Storage','Electrical/Regeneration'};
%     pie(X,explode,labels);


%     while (P_Electrical_Subsystems+P_Electrical_Component_Loss+ ... 
%             P_Mechanical_Component_Loss+P_Mechanical_Braking+P_Driving+ ... 
%         P_Vehicle_Friction)<10
%         P_Electrical_Subsystems = P_Electrical_Subsystems*10;
%         P_Electrical_Component_Loss = P_Electrical_Component_Loss*10;
%         P_Mechanical_Component_Loss = P_Mechanical_Component_Loss*10;
%         P_Mechanical_Braking = P_Mechanical_Braking*10;
%         P_Driving = P_Driving*10;
%         P_Vehicle_Friction = P_Vehicle_Friction*10;
%     end
    figure();
    X = [P_Electrical_Subsystems,P_Electrical_Component_Loss, ... 
        P_Mechanical_Component_Loss,P_Mechanical_Braking,P_Driving, ... 
        P_Vehicle_Friction];
    while sum(X)<10
        X = X*10;
    end
    explode = [1 1 1 1 1 1];
    labels = {'Electrical Subsystems','Electrical Loss', 'Mechanical Loss', ... 
        'Mechanical/Braking','Driving','Vehicle/Friction'};
    title('Energy Usage');
    pie(X,explode,labels)
    
    figure();
    X = [P_Motor_Loss,P_DCDC_Loss, ... 
        P_Battery_Loss,P_Cap_Loss];
    while sum(X)<10
        X = X*10;
    end
    explode = [1 1 1 1];
    labels = {'Motor','DC/DC Converter', 'Batteries', ... 
        'Capacitor'};
    title('Elextrical Loss');
    pie(X,explode,labels)
%     toc
end;