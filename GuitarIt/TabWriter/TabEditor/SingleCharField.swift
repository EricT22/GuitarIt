import SwiftUI
import UIKit

struct SingleCharField: UIViewRepresentable {
    @Binding var text: String

    func makeUIView(context: Context) -> UITextField {
        let tf = UITextField()
        tf.font = UIFont.monospacedSystemFont(ofSize: 16, weight: .regular)
        tf.textAlignment = .center
        tf.delegate = context.coordinator
        tf.backgroundColor = .clear
        tf.layer.cornerRadius = 4
        tf.returnKeyType = .done
        return tf
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: SingleCharField

        init(_ parent: SingleCharField) {
            self.parent = parent
        }

        func textField(_ textField: UITextField,
                       shouldChangeCharactersIn range: NSRange,
                       replacementString string: String) -> Bool {

            // Allow delete
            if string.isEmpty {
                parent.text = ""
                return true
            }

            // Only allow 1 character total
            if parent.text.isEmpty {
                parent.text = String(string.prefix(1))
                return false
            }

            // Already has a character → replace it
            parent.text = String(string.prefix(1))
            return false
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            // If empty, restore "-"
            if parent.text.isEmpty {
                parent.text = "-"
            }

            textField.resignFirstResponder()
            return false   // prevent inserting any characters
        }

    }
}

