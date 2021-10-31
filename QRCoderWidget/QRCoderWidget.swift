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
    var qrCoderData = QRData()
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), qrCode: QRCode.sampleData[0])
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration, qrCode: QRCode.sampleData[0])
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
            let selectedQRCode = codeFromString(name: configuration.chooseQRCode?.identifier)
                    
                    let entries = [SimpleEntry(date: Date(), configuration: configuration, qrCode: selectedQRCode!)]

                    let timeline = Timeline(entries: entries, policy: .never)
                    completion(timeline)
        
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let qrCode: QRCode?
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
        case .systemExtraLarge:
            qrCodeViewBig
        default:
            qrCodeViewSmall
        }
    }
            
            var qrCodeViewSmall: some View {
                VStack(alignment: .center, spacing: 5) {
                    ZStack {
                        ContainerRelativeShape()
                            .fill(.white)
                            .aspectRatio(contentMode: .fit)
                        
                        Image(uiImage: generateQRCode(from: entry.qrCode?.qrString ?? "Long press on the widget to select your QR code."))
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .padding(2)
                        Text(QRData().codes[0].title)
                        }
                    if entry.configuration.showTitle == true {
                        Text(entry.qrCode?.title ?? "Your QR Code")
                            .font(.caption2)
                            .lineLimit(1)
                        
                    }
                }
                .padding(15)
            }
            
            var qrCodeViewBig: some View {
                VStack(alignment: .center, spacing: 5) {
                    ZStack {
                        ContainerRelativeShape()
                            .fill(.white)
                            .aspectRatio(contentMode: .fit)
                        
                        Image(uiImage: generateQRCode(from: entry.qrCode?.qrString ?? "Your QR Code"))
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .padding(2)
                    }
                    if entry.configuration.showTitle == true {
                        Text(entry.qrCode?.title ?? "Your QR Code")
                            .font(.subheadline)
                            .lineLimit(1)
                    }
                }
                .padding(15)
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
        .supportedFamilies([.systemSmall, .systemLarge, .systemExtraLarge])
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
