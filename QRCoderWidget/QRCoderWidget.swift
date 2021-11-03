//
//  QRCoderWidget.swift
//  QRCoderWidget
//
//  Created by Simon Lang on 28.10.21.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    private static var documentsFolder: URL {
        
        let appIdentifier = "group.qrcoder.codes"
        
        return FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appIdentifier)!
    }
    
    private static var fileURL: URL {
        
        return documentsFolder.appendingPathComponent("qrcoder.data")
    }
    
    private func load() -> [QRCode] {
        
        guard let data = try? Data(contentsOf: Self.fileURL) else {
            print("Couldn't load data in intent handler")
            return []
        }
        
        guard let qrCodes = try? JSONDecoder().decode([QRCode].self, from: data) else {
            fatalError("Couldn't decode saved codes data")
        }
        
        return qrCodes
    }

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), qrCode: QRCode.sampleData[0])
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration, qrCode: QRCode.sampleData[0])
        completion(entry)
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        let codes = load()
        
        let selectedQRCode = codeFromString(name: configuration.chooseQRCode?.identifier, data: codes)
        let entries = [SimpleEntry(date: Date(), configuration: configuration, qrCode: selectedQRCode ?? codes.first ?? QRCode.sampleData[0])]
        
        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
        
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let qrCode: QRCode
}

struct PlaceholderView: View {
    var body: some View {
        QRCoderWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), qrCode: QRCode.sampleData[0]))
    }
}

struct QRCoderWidgetEntryView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: Provider.Entry
    
    var body: some View {
        switch family {
        case .systemSmall:
            qrCodeViewSmall
        case .systemLarge:
            qrCodeViewBig
        default:
            qrCodeViewSmall
        }
    }
    
    var qrCodeViewSmall: some View {
        ZStack {
            Rectangle()
                .fill(.white)
            VStack(alignment: .center, spacing: 4) {
                
                Image(uiImage: generateQRCode(from: entry.qrCode.qrString))
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                
                if entry.configuration.showTitle == true {
                    Text(entry.qrCode.title)
                        .font(.caption2)
                        .lineLimit(1)
                        .foregroundColor(.black)
                    
                }
            }
            .padding(10)
        }
        
        
    }
    
    var qrCodeViewBig: some View {
        ZStack {
            Rectangle()
                .fill(.white)
            VStack(alignment: .center, spacing: 2) {
                
                Image(uiImage: generateQRCode(from: entry.qrCode.qrString))
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                
                if entry.configuration.showTitle == true {
                    Text(entry.qrCode.title)
                        .font(.subheadline)
                        .lineLimit(1)
                        .foregroundColor(.black)
                }
            }
            .padding(12)
        }
    }
}


@main
struct QRCoderWidget: Widget {
    let kind: String = "QRCoderWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            QRCoderWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("QRCoder Widget")
        .description("Display your QR Codes in a Widget.")
        .supportedFamilies([.systemSmall, .systemLarge])
    }
}

struct QRCoderWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
                    QRCoderWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), qrCode: QRCode.sampleData[0]))
                                .previewContext(WidgetPreviewContext(family: .systemSmall))
                    
                    QRCoderWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), qrCode: QRCode.sampleData[0]))
                                .previewContext(WidgetPreviewContext(family: .systemLarge))
                }
    }
}
