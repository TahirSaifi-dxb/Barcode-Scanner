//
//  BarcodeScannerView.swift
//  Barcode-Scanner
//
//  Created by Tahir Saifi on 09/09/2024.
//

import SwiftUI

struct BarcodeScannerView: View {
    @State var scannedBarcode = ""
    var body: some View {
        NavigationView{
            VStack{
                ScannerView(scannedCode: $scannedBarcode)
                    .frame(maxWidth: .infinity , maxHeight: 300)
                Spacer().frame(height: 80)
                Label("Scanned Barcode", systemImage: "barcode.viewfinder").font(.title)
                Text(scannedBarcode.isEmpty ? "No Barcode Scanned" : scannedBarcode).font(.largeTitle).bold().foregroundColor(scannedBarcode.isEmpty ? .red : .green).padding()
            
            }.navigationTitle("Barcode Scanner")
        }
    }
}

#Preview {
    BarcodeScannerView()
}
