import CoreML

class test {
    
    
    let crepe: CREPE_SMALL
    
    init() {
        crepe = try! CREPE_SMALL(configuration: .init())
        
        let input = try! MLMultiArray(shape: [1, 1024], dataType: .float32)
        for i in 0..<1024 {
            input[i] = 0.0
        }
        
        let _ = try! crepe.prediction(input: CREPE_SMALLInput(input: input))
        print("ran!")
    }
}
