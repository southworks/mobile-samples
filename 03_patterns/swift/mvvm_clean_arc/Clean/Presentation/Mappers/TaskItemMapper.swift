import Foundation

struct TaskItemMapper {
    func map(_ task: Task) -> TaskItem {
        TaskItem(id: task.id, title: task.title)
    }

    func map(_ tasks: [Task]) -> [TaskItem] {
        tasks.map(map)
    }
}
