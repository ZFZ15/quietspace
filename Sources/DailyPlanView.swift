import SwiftUI

struct DailyPlanView: View {
    @EnvironmentObject private var model: SessionStore

    var snapshot: Bool = false
    var previewDelete: Bool = false
    var onFeedback: ((Feeling) -> Void)? = nil

    @State private var selectedDate = Date()
    @State private var showAdd = false
    @State private var feelingTarget: PlanEvent?
    @State private var reportItem: MoodReportItem?
    @State private var hoveredEventID: UUID?
    @State private var revealedEventID: UUID?
    @State private var deleteTarget: PlanEvent?

    private var events: [PlanEvent] {
        model.plan(for: selectedDate).events
    }

    private var allDone: Bool {
        !events.isEmpty && events.allSatisfy { $0.isDone }
    }

    var body: some View {
        VStack(spacing: 0) {
            dateBar

            if events.isEmpty {
                emptyState
            } else {
                columnHeader
                eventList
            }

            if allDone {
                Button {
                    let result = MoodResult.calculate(events: events)
                    model.markReportGenerated(on: selectedDate, score: result.score)
                    reportItem = MoodReportItem(result: result, date: selectedDate)
                } label: {
                    Text("生成今日份报告")
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.top, 10)
            }

            Button {
                showAdd = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .semibold))
                    Text("添加事件")
                        .font(.qs(13, .medium))
                }
                .foregroundStyle(QS.accent)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(QS.accent.opacity(0.35), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .padding(.top, 8)
        }
        .onAppear {
            guard ProcessInfo.processInfo.arguments.contains("--demo-add") else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                showAdd = true
            }
        }
        .sheet(isPresented: $showAdd) {
            AddEventSheet(
                onSave: { time, place, title in
                    model.addEvent(on: selectedDate, time: time, place: place, title: title)
                    showAdd = false
                },
                onCancel: { showAdd = false }
            )
            .frame(width: 390, height: 620)
            .appLocalized()
        }
        .sheet(item: $feelingTarget) { event in
            FeelingSheet(
                eventTitle: event.title,
                onChoose: { feeling in
                    model.completeEvent(on: selectedDate, id: event.id, feeling: feeling)
                    feelingTarget = nil
                    let notify = onFeedback
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) {
                        notify?(feeling)
                    }
                },
                onCancel: { feelingTarget = nil }
            )
            .frame(width: 390, height: 430)
            .appLocalized()
        }
        .sheet(item: $reportItem) { item in
            DailyReportView(
                result: item.result,
                date: item.date,
                events: model.plan(for: item.date).events
            ) {
                reportItem = nil
            }
            .frame(width: 390, height: 720)
            .appLocalized()
        }
        .alert(Text(L10n.t("删除这个事件？")), isPresented: Binding(
            get: { deleteTarget != nil },
            set: { if !$0 { deleteTarget = nil } }
        )) {
            Button(L10n.t("删除"), role: .destructive) {
                if let target = deleteTarget {
                    model.deleteEvent(on: selectedDate, id: target.id)
                    if revealedEventID == target.id {
                        revealedEventID = nil
                    }
                }
                deleteTarget = nil
            }
            Button(L10n.t("取消"), role: .cancel) {
                deleteTarget = nil
            }
        } message: {
            Text(L10n.t("删除后这条记录会从当天计划中彻底移除，无法恢复。"))
        }
    }

    private var dateBar: some View {
        HStack {
            Button {
                shift(-1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 46)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("前一天")

            Spacer()

            Text(DayKey.display(selectedDate))
                .font(.qs(14, .semibold))
                .foregroundStyle(.white)

            Spacer()

            Button {
                shift(1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 46)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("后一天")
        }
        .frame(height: 46)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(QS.accent)
        )
    }

    private var columnHeader: some View {
        HStack(spacing: 6) {
            Color.clear.frame(width: 34, height: 1)
            Text("#").frame(width: 14, alignment: .leading)
            Text("时间").frame(width: 44, alignment: .leading)
            Text("地点").frame(width: 86, alignment: .leading)
            Text("事件").frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.qs(10, .medium))
        .foregroundStyle(QS.sub)
        .padding(.horizontal, 12)
        .padding(.top, 10)
        .padding(.bottom, 4)
    }

    private var eventList: some View {
        Group {
            if snapshot {
                rows
            } else {
                ScrollView(showsIndicators: false) {
                    rows
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var rows: some View {
        VStack(spacing: 8) {
            ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                eventRow(index: index + 1, event: event)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func eventRow(index: Int, event: PlanEvent) -> some View {
        let canDelete = event.isDone || model.hasReport(on: selectedDate)
        return HStack(alignment: .top, spacing: 6) {
            Button {
                if !event.isDone {
                    feelingTarget = event
                }
            } label: {
                ZStack {
                    Circle()
                        .stroke(event.isDone ? QS.accent : QS.border, lineWidth: 1.5)
                        .frame(width: 20, height: 20)
                    if event.isDone {
                        Circle()
                            .fill(QS.accent)
                            .frame(width: 20, height: 20)
                        Image(systemName: "checkmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                .frame(width: 34, height: 34)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(event.isDone ? "已完成" : "标记完成")

            Text("\(index)")
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundStyle(QS.sub)
                .frame(width: 14, alignment: .leading)
                .padding(.top, 3)

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 6) {
                    Text(event.time)
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .frame(width: 44, alignment: .leading)

                    Text(LocalizedStringKey(event.place))
                        .font(.qs(13))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .truncationMode(.tail)
                        .frame(width: 86, alignment: .leading)
                        .clipped()

                    Text(LocalizedStringKey(event.title))
                        .font(.qs(13, .medium))
                        .lineLimit(2)
                        .frame(minWidth: 100, maxWidth: .infinity, alignment: .leading)
                }
                .foregroundStyle(QS.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
                .layoutPriority(1)

                HStack(alignment: .top, spacing: 6) {
                    Text("建议")
                        .font(.qs(9, .semibold))
                        .foregroundStyle(QS.accent)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(QS.accentSoft))
                        .padding(.top, 1)

                    Text(LocalizedStringKey(event.advice))
                        .font(.qs(13))
                        .foregroundStyle(QS.sub)
                        .lineSpacing(3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if let feeling = event.feeling {
                    HStack(spacing: 5) {
                        Circle()
                            .fill(feeling.color)
                            .frame(width: 5, height: 5)
                        Text(LocalizedStringKey(feeling.title))
                            .font(.qs(10, .medium))
                            .foregroundStyle(feeling.color)
                        Text("已记录")
                            .font(.qs(10))
                            .foregroundStyle(QS.sub.opacity(0.8))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .fill(QS.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .stroke(QS.border, lineWidth: 1)
        )
        .opacity(event.isDone ? 0.5 : 1)
        .simultaneousGesture(
            DragGesture(minimumDistance: 18)
                .onEnded { value in
                    guard canDelete else { return }
                    if value.translation.width < -45 {
                        revealedEventID = event.id
                    } else if value.translation.width > 30 {
                        revealedEventID = nil
                    }
                }
        )
        .overlay(alignment: .trailing) {
            if canDelete,
               hoveredEventID == event.id || revealedEventID == event.id
                || (previewDelete && event.id == events.first?.id) {
                ZStack(alignment: .trailing) {
                    LinearGradient(
                        colors: [QS.surface.opacity(0), QS.surface, QS.surface],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: 132)
                    .allowsHitTesting(false)

                    Button {
                        deleteTarget = event
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "trash")
                                .font(.system(size: 10, weight: .semibold))
                            Text("删除")
                                .font(.qs(11, .medium))
                        }
                        .foregroundStyle(QS.error)
                        .padding(.horizontal, 10)
                        .frame(height: 28)
                        .background(Capsule().fill(QS.surface))
                        .overlay(Capsule().stroke(QS.error.opacity(0.3), lineWidth: 1))
                        .shadow(color: .black.opacity(0.08), radius: 5, y: 2)
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 10)
                    .accessibilityLabel("删除这个事件")
                }
                .frame(maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
            }
        }
        .onHover { inside in
            if inside {
                hoveredEventID = event.id
            } else if hoveredEventID == event.id {
                hoveredEventID = nil
            }
        }
        .contextMenu {
            if canDelete {
                Button(L10n.t("删除这个事件"), role: .destructive) {
                    deleteTarget = event
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 26, weight: .light))
                .foregroundStyle(QS.accent)
            Text("还没有安排")
                .font(.qs(14, .semibold))
                .foregroundStyle(QS.ink)
            Text("把今天要做的事写下来，\n完成后记录当时的感受。")
                .font(.qs(12))
                .foregroundStyle(QS.sub)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 20)
    }

    private func shift(_ days: Int) {
        if let date = Calendar.current.date(byAdding: .day, value: days, to: selectedDate) {
            selectedDate = date
            feelingTarget = nil
            reportItem = nil
            hoveredEventID = nil
            revealedEventID = nil
        }
    }
}

struct MoodReportItem: Identifiable {
    let id = UUID()
    let result: MoodResult
    let date: Date
}

// MARK: - 添加事件

struct AddEventSheet: View {
    var onSave: (String, String, String) -> Void
    var onCancel: () -> Void

    @State private var hour = Calendar.current.component(.hour, from: Date())
    @State private var minute = Calendar.current.component(.minute, from: Date())
    @State private var place = ""
    @State private var title = ""

    var body: some View {
        ZStack {
            QS.bg.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("添加事件")
                        .font(.qs(22, .semibold))
                        .foregroundStyle(QS.ink)
                    Spacer()
                    Button(action: onCancel) {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(QS.sub)
                            .frame(width: 30, height: 30)
                            .background(Circle().fill(QS.chip))
                    }
                    .buttonStyle(.plain)
                }

                Text("写下时间、地点和要做的事。")
                    .font(.qs(13))
                    .foregroundStyle(QS.sub)
                    .padding(.top, 8)

                Spacer().frame(height: 20)

                timePicker
                SoftField(icon: "mappin.and.ellipse", placeholder: "地点，例如 图书馆", text: $place)
                    .padding(.top, 14)
                SoftField(icon: "text.alignleft", placeholder: "事件，例如 复习期中考试", text: $title)
                    .padding(.top, 12)

                Spacer()

                Button {
                    onSave(
                        String(format: "%02d:%02d", hour, minute),
                        place.trimmingCharacters(in: .whitespaces),
                        title.trimmingCharacters(in: .whitespaces)
                    )
                } label: {
                    Text("保存到这一天")
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(title.trimmingCharacters(in: .whitespaces).isEmpty ? 0.45 : 1)

                Text("保存后会为这件事生成一条初步建议。")
                    .font(.qs(10))
                    .foregroundStyle(QS.sub.opacity(0.8))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
                    .padding(.bottom, 8)
            }
            .padding(.horizontal, 28)
            .padding(.top, 22)
        }
    }

    private var timePicker: some View {
        HStack(spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: "clock")
                    .font(.system(size: 15, weight: .medium))
                    .frame(width: 20)
                Text("时间：")
                    .font(.qs(15, .medium))
            }
            .foregroundStyle(QS.sub)

            Spacer(minLength: 6)

            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(QS.accentSoft.opacity(0.8))
                    .frame(width: 150, height: 40)

                HStack(spacing: 4) {
                    TimeWheel(values: Array(0...23), selection: $hour)
                    Text(":")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundStyle(QS.sub)
                        .padding(.bottom, 2)
                    TimeWheel(values: Array(0...59), selection: $minute)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .frame(height: 180)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(QS.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(QS.border, lineWidth: 1)
        )
    }
}

struct TimeWheel: View {
    let values: [Int]
    @Binding var selection: Int

    @State private var position: CGFloat
    @State private var dragStart: CGFloat?

    private let rowHeight: CGFloat = 50
    private let wheelHeight: CGFloat = 150

    init(values: [Int], selection: Binding<Int>) {
        self.values = values
        _selection = selection
        _position = State(initialValue: CGFloat(selection.wrappedValue))
    }

    var body: some View {
        GeometryReader { geo in
            let centerY = geo.size.height / 2

            ZStack {
                ForEach(Array(values.enumerated()), id: \.element) { index, value in
                    let delta = shortestDelta(index: index)

                    if abs(delta) <= 2.6 {
                        Text(String(format: "%02d", value))
                            .font(
                                .system(
                                    size: abs(delta) < 0.5 ? 24 : 18,
                                    weight: abs(delta) < 0.5 ? .semibold : .regular,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(abs(delta) < 0.5 ? QS.accent : QS.sub.opacity(0.65))
                            .position(
                                x: geo.size.width / 2,
                                y: centerY + delta * rowHeight
                            )
                            .opacity(1 - min(abs(delta) / 2.6, 1) * 0.45)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .clipped()
            .mask(
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0),
                        .init(color: .black, location: 0.18),
                        .init(color: .black, location: 0.82),
                        .init(color: .clear, location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if dragStart == nil {
                            dragStart = position
                        }
                        let base = dragStart ?? position
                        position = base - value.translation.height / rowHeight
                    }
                    .onEnded { value in
                        let base = dragStart ?? position
                        let projected = base - value.predictedEndTranslation.height / rowHeight
                        dragStart = nil

                        let target = projected.rounded()
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                            position = target
                        }
                        settle(at: target)
                    }
            )
        }
        .frame(width: 64, height: wheelHeight)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(format: "%02d", selection))
        .accessibilityAdjustableAction { direction in
            let delta: CGFloat = direction == .increment ? 1 : -1
            let target = position + delta
            withAnimation(.spring(response: 0.3, dampingFraction: 0.82)) {
                position = target
            }
            settle(at: target)
        }
    }

    private func shortestDelta(index: Int) -> CGFloat {
        let count = CGFloat(values.count)
        var delta = CGFloat(index) - position
        delta = delta.truncatingRemainder(dividingBy: count)
        if delta > count / 2 { delta -= count }
        if delta < -count / 2 { delta += count }
        return delta
    }

    private func settle(at target: CGFloat) {
        let count = CGFloat(values.count)
        var normalized = target.truncatingRemainder(dividingBy: count)
        if normalized < 0 { normalized += count }
        let index = Int(normalized.rounded()) % values.count
        selection = values[index]

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            position = CGFloat(index)
        }
    }
}

// MARK: - 感受选择

struct FeelingSheet: View {
    let eventTitle: String
    var onChoose: (Feeling) -> Void
    var onCancel: () -> Void

    var body: some View {
        ZStack {
            QS.bg.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("记录感受")
                        .font(.qs(22, .semibold))
                        .foregroundStyle(QS.ink)
                    Spacer()
                    Button(action: onCancel) {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(QS.sub)
                            .frame(width: 30, height: 30)
                            .background(Circle().fill(QS.chip))
                    }
                    .buttonStyle(.plain)
                }

                Text("在完成「\(eventTitle)」的过程中，你的感受是：")
                    .font(.qs(15))
                    .foregroundStyle(QS.ink)
                    .lineSpacing(4)
                    .padding(.top, 14)

                Spacer().frame(height: 20)

                VStack(spacing: 10) {
                    feelingRow(.calm, detail: "基本没有不适，节奏还在自己手里")
                    feelingRow(.tense, detail: "有些吃力，但还能继续完成")
                    feelingRow(.overload, detail: "明显不适，需要离开或休息")
                }

                Spacer()
            }
            .padding(.horizontal, 28)
            .padding(.top, 22)
            .padding(.bottom, 20)
        }
    }

    private func feelingRow(_ feeling: Feeling, detail: LocalizedStringKey) -> some View {
        Button {
            onChoose(feeling)
        } label: {
            HStack(spacing: 12) {
                Circle()
                    .fill(feeling.color)
                    .frame(width: 12, height: 12)

                VStack(alignment: .leading, spacing: 3) {
                    Text(LocalizedStringKey(feeling.title))
                        .font(.qs(17, .semibold))
                        .foregroundStyle(QS.ink)
                    Text(detail)
                        .font(.qs(11))
                        .foregroundStyle(QS.sub)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(QS.sub.opacity(0.6))
            }
            .padding(.horizontal, 16)
            .frame(height: 74)
            .background(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(feeling.color.opacity(0.09))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .stroke(feeling.color.opacity(0.35), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
