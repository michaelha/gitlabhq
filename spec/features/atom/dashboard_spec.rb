require 'spec_helper'

describe "Dashboard Feed"  do
  describe "GET /" do
    let!(:user) { create(:user, name: "Jonh") }

    context "projects atom feed via private token" do
      it "renders projects atom feed" do
        visit dashboard_projects_path(:atom, private_token: user.private_token)
        expect(body).to have_selector('feed title')
      end
    end

    context "projects atom feed via RSS token" do
      it "renders projects atom feed" do
        visit dashboard_projects_path(:atom, rss_token: user.rss_token)
        expect(body).to have_selector('feed title')
      end
    end

    context 'feed content' do
      let(:project) { create(:empty_project) }
      let(:issue) { create(:issue, project: project, author: user, description: '') }
      let(:note) { create(:note, noteable: issue, author: user, note: 'Bug confirmed', project: project) }

      before do
        project.team << [user, :master]
        issue_event(issue, user)
        note_event(note, user)
        visit dashboard_projects_path(:atom, rss_token: user.rss_token)
      end

      it "has issue opened event" do
        expect(body).to have_content("#{user.name} opened issue ##{issue.iid}")
      end

      it "has issue comment event" do
        expect(body)
          .to have_content("#{user.name} commented on issue ##{issue.iid}")
      end
    end
  end

  def issue_event(issue, user)
    EventCreateService.new.open_issue(issue, user)
  end

  def note_event(note, user)
    EventCreateService.new.leave_note(note, user)
  end
end
