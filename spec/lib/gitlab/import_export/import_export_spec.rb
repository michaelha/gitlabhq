require 'spec_helper'

describe Gitlab::ImportExport do
  describe 'export filename' do
    let(:group) { create(:group, :nested) }
    let(:project) { create(:empty_project, :public, path: 'project-path', namespace: group) }

    it 'contains the project path' do
      expect(described_class.export_filename(project: project)).to include(project.path)
    end

    it 'contains the namespace path' do
      expect(described_class.export_filename(project: project)).to include(project.namespace.full_path.tr('/', '_'))
    end

    it 'does not go over a certain length' do
      project.path = 'a' * 100

      expect(described_class.export_filename(project: project).length).to be < 70
    end
  end
end
