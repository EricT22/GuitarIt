// Conversion to MLprogram reduced CREPE to core nn features
// NN returns an activation vector with 360 bins that represent pitch frequencies
// Have to compute predicted frequency and confidence from these vectors
// Will use the same math as used in the CREPE Github library
// https://github.com/marl/crepe/blob/master/crepe/core.py

import CoreML

class Crepe {
    private let crepe: CREPE_SMALL
    
    init() {
        crepe = try! CREPE_SMALL(configuration: .init())
    }
    
    func predict(from audioFrame: [Float]) -> (pitch: Float, confidence: Float)?{
        guard let input = arrayToMLArray(audioFrame) else { return nil }
        
        guard let output = try? crepe.prediction(input: input) else { return nil }
        
        let bins = output.Identity
        
        return analyzeCREPEOutput(bins)
    }
    
    func analyzeCREPEOutput(_ bins : MLMultiArray) -> (pitch: Float, confidence: Float) {
        var center = 0
        var maxVal = -Float.infinity
        
        // Confidence is just the highest activation value (line 258 of core.py in Github source code)
        for i in 0..<360 {
            let val = bins[i].floatValue
            
            if val > maxVal {
                maxVal = val
                center = i
            }
            
        }

        let cents = toLocalAverageCents(bins: bins, center: center)
        
        return (pitch: centsToHz(cents: cents), confidence: maxVal)
    }
    
    // Translation into swift of function of the same name in Github source code
    func toLocalAverageCents(bins: MLMultiArray, center: Int) -> Float {
        // Building cents mapping
        var centsMapping = [Float](repeating: 0.0, count: 360)
        let offset: Float = 1997.3794084376191
        
        for i in 0..<360 {
            let lin = Float(i) * (7180.0 / 359.0)
            centsMapping[i] = lin + offset // Numpy linspace
        }
        
        let start = max(0, center - 4)
        let end = min(359, center + 4)
        
        var productSum: Float = 0.0
        var weightSum: Float = 0.0
        
        for i in start...end { // inclusive end
            let weight = bins[i].floatValue
            
            productSum += weight * centsMapping[i]
            weightSum += weight
        }
        
        return productSum / weightSum
    }
    
    func centsToHz(cents: Float) -> Float {
        // From line 265 of Github source code
        return 10.0 * pow(2.0, cents / 1200.0)
    }
    
    
    func arrayToMLArray(_ frame : [Float]) -> MLMultiArray? {
        guard frame.count == 1024 else { return nil }
        
        let shape = [1, 1024] as [NSNumber]
        
        
        guard let multiArray = try? MLMultiArray(shape: shape, dataType: .float32) else { return nil }
        
        for i in 0..<1024 {
            multiArray[i] = NSNumber(value: frame[i])
        }
        
        return multiArray
        
    }
    
}
