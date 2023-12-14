//
//  CarPlayUI.swift
//
//
//  Created by Alsey Coleman Miller on 12/13/23.
//

#if os(iOS)
import Foundation
import UIKit
import CarPlay
import TokamakCore

// MARK: Environment & State

public typealias Environment = TokamakCore.Environment
public typealias EnvironmentObject = TokamakCore.EnvironmentObject

public typealias Binding = TokamakCore.Binding
public typealias ObservableObject = TokamakCore.ObservableObject
public typealias ObservedObject = TokamakCore.ObservedObject
public typealias Published = TokamakCore.Published
public typealias State = TokamakCore.State
public typealias StateObject = TokamakCore.StateObject

// MARK: Modifiers & Styles

public typealias ViewModifier = TokamakCore.ViewModifier
public typealias ModifiedContent = TokamakCore.ModifiedContent

public typealias DefaultTextFieldStyle = TokamakCore.DefaultTextFieldStyle
public typealias PlainTextFieldStyle = TokamakCore.PlainTextFieldStyle
public typealias RoundedBorderTextFieldStyle = TokamakCore.RoundedBorderTextFieldStyle
public typealias SquareBorderTextFieldStyle = TokamakCore.SquareBorderTextFieldStyle

public typealias DefaultListStyle = TokamakCore.DefaultListStyle
public typealias PlainListStyle = TokamakCore.PlainListStyle
public typealias InsetListStyle = TokamakCore.InsetListStyle
public typealias GroupedListStyle = TokamakCore.GroupedListStyle
public typealias InsetGroupedListStyle = TokamakCore.InsetGroupedListStyle
public typealias SidebarListStyle = TokamakCore.SidebarListStyle

public typealias DefaultPickerStyle = TokamakCore.DefaultPickerStyle
public typealias PopUpButtonPickerStyle = TokamakCore.PopUpButtonPickerStyle
public typealias RadioGroupPickerStyle = TokamakCore.RadioGroupPickerStyle
public typealias SegmentedPickerStyle = TokamakCore.SegmentedPickerStyle
public typealias WheelPickerStyle = TokamakCore.WheelPickerStyle

public typealias ToggleStyle = TokamakCore.ToggleStyle
public typealias ToggleStyleConfiguration = TokamakCore.ToggleStyleConfiguration

public typealias ButtonStyle = TokamakCore.ButtonStyle
public typealias ButtonStyleConfiguration = TokamakCore.ButtonStyleConfiguration
public typealias DefaultButtonStyle = TokamakCore.DefaultButtonStyle

public typealias ColorScheme = TokamakCore.ColorScheme

// MARK: Shapes

public typealias Shape = TokamakCore.Shape

public typealias Capsule = TokamakCore.Capsule
public typealias Circle = TokamakCore.Circle
public typealias Ellipse = TokamakCore.Ellipse
public typealias Path = TokamakCore.Path
public typealias Rectangle = TokamakCore.Rectangle
public typealias RoundedRectangle = TokamakCore.RoundedRectangle

// MARK: Primitive values

public typealias Color = TokamakCore.Color
public typealias Font = TokamakCore.Font

#if !canImport(CoreGraphics)
public typealias CGAffineTransform = TokamakCore.CGAffineTransform
#endif

// MARK: Views

public typealias Button = TokamakCore.Button
public typealias DisclosureGroup = TokamakCore.DisclosureGroup
public typealias Divider = TokamakCore.Divider
public typealias ForEach = TokamakCore.ForEach
public typealias GeometryReader = TokamakCore.GeometryReader
public typealias GridItem = TokamakCore.GridItem
public typealias Group = TokamakCore.Group
public typealias HStack = TokamakCore.HStack
public typealias Image = TokamakCore.Image
public typealias LazyHGrid = TokamakCore.LazyHGrid
public typealias LazyVGrid = TokamakCore.LazyVGrid
public typealias List = TokamakCore.List
public typealias NavigationLink = TokamakCore.NavigationLink
public typealias NavigationView = TokamakCore.NavigationView
public typealias OutlineGroup = TokamakCore.OutlineGroup
public typealias Picker = TokamakCore.Picker
public typealias ScrollView = TokamakCore.ScrollView
public typealias Section = TokamakCore.Section
public typealias SecureField = TokamakCore.SecureField
public typealias Slider = TokamakCore.Slider
public typealias Spacer = TokamakCore.Spacer
public typealias Text = TokamakCore.Text
public typealias TextField = TokamakCore.TextField
public typealias Toggle = TokamakCore.Toggle
public typealias VStack = TokamakCore.VStack
public typealias ZStack = TokamakCore.ZStack

// MARK: Special Views

public typealias View = TokamakCore.View
public typealias AnyView = TokamakCore.AnyView
public typealias EmptyView = TokamakCore.EmptyView

// MARK: App & Scene

public typealias App = TokamakCore.App
public typealias Scene = TokamakCore.Scene
public typealias WindowGroup = TokamakCore.WindowGroup
public typealias ScenePhase = TokamakCore.ScenePhase
public typealias AppStorage = TokamakCore.AppStorage
public typealias SceneStorage = TokamakCore.SceneStorage

// MARK: Misc

public typealias ViewBuilder = TokamakCore.ViewBuilder

#endif
