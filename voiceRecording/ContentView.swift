//
//  ContentView.swift
//  voiceRecording
//
//  Created by Maksymilian Rechnio on 04/04/2024.
//

import SwiftUI
//I am importing AVKit as it is used to actually capture the voice that I record
import AVKit



struct ContentView: View {
    var body: some View {
        
        HomeView()
            .preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
        
    }
}


struct HomeView: View {
    
    @State var record = false
    @State var session : AVAudioSession!
    @State var recorder : AVAudioRecorder!
    @State var alert = false
    
    //This is where I begin the steps to fetch the audios I record.
    @State var audios : [URL] = []
    
    
    var body: some View {
        NavigationStack {
            VStack {
                
                List(self.audios, id: \.self){i in
                    
                    
                    //This only prints the file name
                    Text(i.relativeString)
                    
                    
                }
                
                
                Button(action: {
                    
                    do {
                        
                        if self.record {
                            //This is a fail-safe and it stops recording and saves
                            self.recorder.stop()
                            self.record.toggle()
                            //this updates the data for every recording
                            self.fetchAudios()
                            return
                            
                        }
                        
                        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                        
                        let fileName = url.appendingPathComponent("myRecording-\(self.audios.count + 1).m4a")
                        
                        let settings = [
                            
                            AVFormatIDKey : Int(kAudioFormatMPEG4AAC),
                            AVSampleRateKey :12000,
                            AVNumberOfChannelsKey : 1,
                            AVEncoderAudioQualityKey : AVAudioQuality.high.rawValue
                        ]
                        
                        self.recorder = try AVAudioRecorder(url: fileName, settings: settings)
                        self.recorder.record()
                        self.record.toggle()
                    }
                    
                    catch {
                        
                        print(error.localizedDescription)
                    }
                    
                    
                }) {
                    ZStack {
                        Circle()
                            .fill(Color(.red))
                            .frame(width: 70, height: 70)
                        
                        if self.record {
                            
                            Circle()
                                .stroke(Color(.white), lineWidth: 6)
                                .frame(width: 85, height: 85)
                        }
                        
                    }
                }
                .padding(.vertical, 25)
            }
            .navigationTitle("Record Audio")
        }
        
        
        .alert(isPresented: self.$alert, content: {
            Alert(title: Text("Error"), message: Text("Enable Access!"))
        })
        .onAppear {
            
            do {
                //This initialises the session
                self.session = AVAudioSession.sharedInstance()
                try self.session.setCategory(.playAndRecord)
                
                //Building a request for the user to record.
                self.session.requestRecordPermission{ (status) in
                    
                    
                    if !status {
                        //This outputs an error message
                        self.alert.toggle()
                        
                    }
                    
                    else {
                        
                        self.fetchAudios()
                        
                    }
                }
                
            }
            
            catch {
                
                print(error.localizedDescription)
                
            }
        }
    }
    
    func fetchAudios() {
        
        do {
            
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            let result = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .producesRelativePathURLs)
            
            self.audios.removeAll()
            
            for i in result {
                
                self.audios.append(i)
                
            }
            
        }
        
        catch {
            
            print(error.localizedDescription)
        }
        
    }
    
}


#Preview {
    ContentView()
}
