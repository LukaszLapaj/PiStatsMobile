//
//  StatsView.swift
//  PiStatsMobile
//
//  Created by Fernando Bunn on 04/07/2020.
//

import SwiftUI

struct StatsView: View {
    @ObservedObject var dataProvider: PiholeDataProvider
    @EnvironmentObject private var userPreferences: UserPreferences
    @State private var isShowingDisableOptions = false

    var body: some View {
        VStack(alignment: .leading, spacing: UIConstants.Geometry.defaultPadding) {
            StatusHeaderView(dataProvider: dataProvider)
            
            VStack {
                ForEach(dataProvider.pollingErrors, id: \.self) { error in
                    Label {
                        Text(error)
                            .fixedSize(horizontal: false, vertical: true)
                    } icon: {
                        Image(systemName: UIConstants.SystemImages.errorMessageWarning)
                            .foregroundColor(UIConstants.Colors.errorMessage)
                    }
                    .font(.headline)
                }
            }
            
            if userPreferences.displayStatsAsList {
                statsList()
            } else {
                statsGrid()
            }
            
            if dataProvider.canDisplayEnableDisableButton {
                Divider()
                if dataProvider.status == .allDisabled {
                    enableButton()
                } else {
                    disableButton()
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(UIConstants.Geometry.defaultCornerRadius)
        .shadow(radius: UIConstants.Geometry.shadowRadius)
        .padding()
        
    }
    
    private func statsList() -> some View {
        return VStack (alignment: .leading){
            StatsItemView(type: .totalQueries, label: dataProvider.totalQueries)
            StatsItemView(type: .queriesBlocked, label: dataProvider.queriesBlocked)
            StatsItemView(type: .percentBlocked, label: dataProvider.percentBlocked)
            StatsItemView(type: .domainsOnBlockList, label: dataProvider.domainsOnBlocklist)
        }
    }
    
    private func statsGrid() -> some View {
        return Group {
            HStack {
                StatsItemView(type: .totalQueries, label: dataProvider.totalQueries)
                StatsItemView(type: .queriesBlocked, label: dataProvider.queriesBlocked)
            }
            HStack {
                StatsItemView(type: .percentBlocked, label: dataProvider.percentBlocked)
                StatsItemView(type: .domainsOnBlockList, label: dataProvider.domainsOnBlocklist)
            }
        }
    }
    
    
    private func disableButton() -> some View {
        Button(action: {
            if userPreferences.disablePermanently {
                dataProvider.disablePiHole()
            } else {
                isShowingDisableOptions = true
            }
            
        }, label: {
            HStack (spacing: 0) {
                Label(UIConstants.Strings.disableButton, systemImage: UIConstants.SystemImages.disablePiholeButton)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(Color(.systemBlue))
            .cornerRadius(UIConstants.Geometry.defaultCornerRadius)
        })
        .actionSheet(isPresented: $isShowingDisableOptions) {
            ActionSheet(title: Text(UIConstants.Strings.disablePiholeOptionsTitle), buttons: [
                .default(Text(UIConstants.Strings.disablePiholeOptions30Seconds)) {
                    dataProvider.disablePiHole(seconds: 30)
                },
                .default(Text(UIConstants.Strings.disablePiholeOptions1Minute)) {
                    dataProvider.disablePiHole(seconds: 60)
                },
                .default(Text(UIConstants.Strings.disablePiholeOptions5Minutes)) {
                    dataProvider.disablePiHole(seconds: 300)
                },
                .default(Text(UIConstants.Strings.disablePiholeOptionsPermanently)) {
                    dataProvider.disablePiHole()
                },
                .cancel()
            ])
        }
    }
    
    private func enableButton() -> some View {
        Button(action: {
            dataProvider.enablePiHole()
        }, label: {
            HStack (spacing: 0) {
                Label(UIConstants.Strings.enableButton, systemImage: UIConstants.SystemImages.enablePiholeButton)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(Color(.systemBlue))
            .cornerRadius(UIConstants.Geometry.defaultCornerRadius)
        })
    }
}


fileprivate struct StatusHeaderView: View {
    @ObservedObject var dataProvider: PiholeDataProvider
    
    var body: some View {
        HStack {
            Label {
                Text(dataProvider.name)
                    .foregroundColor(.primary)
                    .fontWeight(.bold)
            } icon: {
                if dataProvider.hasErrorMessages {
                    Image(systemName: UIConstants.SystemImages.piholeStatusWarning)
                        .foregroundColor(UIConstants.Colors.statusWarning)
                } else if dataProvider.status == .allEnabled {
                    Image(systemName: UIConstants.SystemImages.piholeStatusOnline)
                        .foregroundColor(UIConstants.Colors.statusOnline)
                } else {
                    Image(systemName: UIConstants.SystemImages.piholeStatusOffline)
                        .foregroundColor(UIConstants.Colors.statusOffline)
                }
            }
            .font(.title2)
        }
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView(dataProvider: PiholeDataProvider.previewData())
    }
}
