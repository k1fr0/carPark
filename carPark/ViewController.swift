//
//  ViewController.swift
//  carPark
//
//  Created by Кирилл  on 05.10.2024.
//

import UIKit
class Vehicle {
    // марка транспортного средства
    let mark: String
    // модель транспортного средства
    let model: String
    // год выпуска
    let year: Int
    // грузоподъемность в килограммах
    let capacity: Int
    // опциональный массив типов грузов, если пустой, то может перевозить любой тип груза
    let types: [CargoType]?
    // свойство, обозначающее текущую нагрузку на машину
    var currentLoad: Int
    // объем бака в литрах
    let tankVolume: Int
    // расход топлива на 1 км
    var fuelConsumption: Double

    init(mark: String, model: String, year: Int, capacity: Int, types: [CargoType]?, currentLoad: Int = 0, tankVolume: Int, fuelConsumption: Double) {
        self.mark = mark
        self.model = model
        self.year = year
        self.capacity = capacity
        self.types = types
        self.currentLoad = currentLoad
        self.tankVolume = tankVolume
        self.fuelConsumption = fuelConsumption
    }

    // метод для загрузки груза, который увеличивает текущее значение груза в машине
    func loadCargo(cargo: Cargo) {
        // Проверяем, поддерживается ли тип груза транспортным средством
        if let types = types, !types.contains(cargo.type) {
            print("\(mark) \(model) - Ошибка: Нельзя перевозить груз типа \(cargo.type)")
            return
        }
        
        // проверяем, не превышает ли грузоподъемность
        if currentLoad + (cargo.weight ?? 0) > capacity {
            print("\(mark) \(model) - Ошибка: Перегрузка")
        } else {
            currentLoad += cargo.weight ?? 0
            print("Груз загружен в \(mark) \(model)")
        }
    }

    // метод для разгрузки транспортного средства, обнуляющий текущую нагрузку
    func unloadCargo() {
        if currentLoad != 0{
            currentLoad = 0
            print("Груз выгружен из \(mark) \(model)")
        }else{
            print("\(mark) \(model) был пуст")
        }
    }
    
    // метод для проверки, сможет ли транспортное средство перевезти груз на указанное расстояние
    func canGo(cargo: [Cargo], path: Int) -> Bool {
        

        let maxDistance = Double(tankVolume) / 2 / fuelConsumption // Максимальное расстояние на половине бака
        if Double(path) > maxDistance {
            print(" \(mark) \(model) - Ошибка: Невозможно завершить поездку, нехватка топлива")
            return false
        }

        print(" \(mark) \(model) - Транспортное средство может завершить поездку")
        return true
    }
}

class Truck: Vehicle {
    // булево значение, обозначающее наличие прицепа
    let trailerAttached: Bool
    // целое число, представляющее грузоподъемность прицепа (может быть опциональным)
    let trailerCapacity: Int?
    // типы грузов, которые могут перевозиться (может быть опциональным)
    let trailerTypes: [CargoType]?

    init(mark: String, model: String, year: Int, capacity: Int, types: [CargoType]?,tankVolume: Int, fuelConsumption: Double, trailerAttached: Bool, trailerCapacity: Int?, trailerTypes: [CargoType]?) {
        self.trailerAttached = trailerAttached
        self.trailerCapacity = trailerCapacity
        self.trailerTypes = trailerTypes
        super.init(mark: mark, model: model, year: year, capacity: capacity, types: types, tankVolume: tankVolume, fuelConsumption: fuelConsumption)
    }

    // переопределение метода loadCargo для учета загрузки прицепа
    override func loadCargo(cargo: Cargo) {
        let totalCapacity = capacity + (trailerCapacity ?? 0)
        if trailerAttached {
            // Проверяем типы грузов для прицепа
            if let trailerTypes = trailerTypes, !trailerTypes.contains(cargo.type) {
                print("\(mark) \(model) - Ошибка: Нельзя перевозить груз типа \(cargo.type) в прицепе")
                return
            }
        }
        
        // проверяем суммарную грузоподъемность транспортного средства и прицепа
        if currentLoad + (cargo.weight ?? 0) <= totalCapacity {
            currentLoad += cargo.weight ?? 0
            print("Груз загружен в \(mark) \(model) с прицепом")
        } else {
            print("\(mark) \(model) - Ошибка: Перегрузка с прицепом")
        }
    }
}

struct Cargo {
    // строка с описанием груза
    let description: String
    // целое число, обозначающее вес груза
    let weight: Int?
    // тип груза
    let type: CargoType

    // инициализатор, который проверяет, что вес не отрицателен
    init?(weight: Int, type: CargoType, description: String) {
        if weight < 0 {
            return nil
        }
        self.weight = weight
        self.type = type
        self.description = description
    }
}

enum CargoType {
    // хрупкий груз
    case fragile
    // скоропортящийся груз
    case perishable
    // сыпучий груз
    case bulk
}

class Fleet {
    // массив транспортных средств (объекты класса Vehicle)
    var vehicles: [Vehicle]

    init(vehicles: [Vehicle]) {
        self.vehicles = vehicles
    }

    // метод для добавления транспортного средства в автопарк
    func addVehicle(_ vehicle: Vehicle) {
        vehicles.append(vehicle)
    }

    // метод, возвращающий общую грузоподъемность всех транспортных средств в автопарке
    func totalCapacity() -> Int {
            return vehicles.reduce(0) { $0 + $1.capacity }
        }

        // метод, возвращающий текущую суммарную нагрузку автопарка
        func totalCurrentLoad() -> Int {
            return vehicles.reduce(0) { $0 + $1.currentLoad }
        }

        // метод для вывода информации об автопарке
        func info() {
            print("Автопарк состоит из \(vehicles.count) транспортных средств.")
            print("Общая грузоподъемность: \(totalCapacity()) кг.")
            print("Текущая нагрузка: \(totalCurrentLoad()) кг.")
        }
    // метод для проверки автопарка, может ли он выполнить рейс
        func canTransportCargo(cargo: [Cargo], path: Int) -> Bool {
            for vehicle in vehicles {
                if vehicle.canGo(cargo: cargo, path: path) {
                    return true
                }
            }
            print("Ни один автомобиль в парке не сможет совершить поездку для данного типа")
            return false
        }
    }

    // пример использования
func primer(){
    let fragileCargo = Cargo(weight: 1000, type: .fragile, description: "Mirror")!
    let perishableCargo = Cargo(weight: 100, type: .perishable, description: "Milk")!
    let bulkCargo = Cargo(weight: 700, type: .bulk, description: "Concrete")!
    
    let vehicle1 = Vehicle(mark: "Tesla", model: "Semi", year: 2017, capacity: 1000, types: [.bulk, .fragile], tankVolume: 300, fuelConsumption: 0.5)
    let vehicle2 = Vehicle(mark: "Volvo", model: "V60", year: 2020, capacity: 500, types: [.perishable], tankVolume: 400, fuelConsumption: 0.65)
    let vehicle3 = Vehicle(mark: "Mercedes-Benz", model: "Actros", year: 2023, capacity: 800, types: nil, tankVolume: 200, fuelConsumption: 0.38)
    let vehicle4 = Vehicle(mark: "Scania", model: "S-series", year: 2019, capacity: 600, types: [.bulk], tankVolume: 250, fuelConsumption: 0.55)
    
    let truck1 = Truck(mark: "Krone", model: "SD", year: 2019, capacity: 400, types: [.bulk], tankVolume: 550, fuelConsumption: 0.75, trailerAttached: true, trailerCapacity: 500, trailerTypes: [.bulk])
    let truck2 = Truck(mark: "PIN", model: "CHO2", year: 2024, capacity: 200, types: [.perishable], tankVolume: 650, fuelConsumption: 0.8, trailerAttached: true, trailerCapacity: 300, trailerTypes: [.perishable])
    let truck3 = Truck(mark: "Schmitz", model: "Cargobull SKO", year: 2021, capacity: 300, types: nil, tankVolume: 400, fuelConsumption: 0.6, trailerAttached: false, trailerCapacity: 400, trailerTypes: nil)
    
    let fleet = Fleet(vehicles: [vehicle1, vehicle2, vehicle3, vehicle4, truck1, truck2, truck3])
    fleet.info()
    
    // пробуем загрузить груз
    vehicle1.loadCargo(cargo: fragileCargo)
    vehicle2.loadCargo(cargo: perishableCargo)
    vehicle3.loadCargo(cargo: bulkCargo)
    vehicle4.loadCargo(cargo: perishableCargo)
    truck1.loadCargo(cargo: bulkCargo)
    truck1.loadCargo(cargo: bulkCargo)
    truck1.loadCargo(cargo: fragileCargo)
    
    fleet.info()
    
    // выгружаем груз
    vehicle1.unloadCargo()
    truck2.unloadCargo()
    fleet.info()
    
    // проверяем, может ли автопарк перевезти грузы на заданное расстояние
    fleet.canTransportCargo(cargo: [fragileCargo], path: 400)
    fleet.canTransportCargo(cargo: [bulkCargo], path: 300)
    fleet.canTransportCargo(cargo: [perishableCargo], path: 100)
}
class ViewController: UIViewController {

    override func viewDidLoad() {
        
        primer()

        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

// с топливным баком, возможно перемудрил, сильно громоздко выглядит. Как можно было лучше/компактнее реализовать?
