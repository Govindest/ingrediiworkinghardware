import SwiftUI

struct SectionHeader: View {
  @Binding var selectedSection: StorageSection
  @Binding var isAddMode: Bool
  var onSectionChange: (StorageSection) -> Void

  var body: some View {
    HStack {
      Menu {
        Picker("", selection: $selectedSection) {
          ForEach(StorageSection.allCases) { sec in
            Text(sec.rawValue).tag(sec)
          }
        }
      } label: {
        Label(selectedSection.rawValue, systemImage: "chevron.down")
          .font(.headline)
      }
      .onChange(of: selectedSection, perform: onSectionChange)

      Spacer()

      Button {
        isAddMode.toggle()
      } label: {
        Image(systemName: isAddMode ? "plus.circle" : "minus.circle")
          .font(.title2)
          .foregroundColor(isAddMode ? .green : .red)
      }
    }
    .padding(.vertical, 4)
  }
}
