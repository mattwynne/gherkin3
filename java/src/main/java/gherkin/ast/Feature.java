package gherkin.ast;

import java.util.Collections;
import java.util.List;

public class Feature extends Node {
    private final List<Tag> tags;
    private final String language;
    private final String keyword;
    private final String name;
    private final String description;
    private final Background background;
    private final List<ScenarioDefinition> scenarioDefinitions;
    private final List<Comment> comments;

    public Feature(
            List<Tag> tags,
            Location location,
            String language,
            String keyword,
            String name,
            String description,
            Background background,
            List<ScenarioDefinition> scenarioDefinitions,
            List<Comment> comments) {
        super(location);
        this.tags = Collections.unmodifiableList(tags);
        this.language = language;
        this.keyword = keyword;
        this.name = name;
        this.description = description;
        this.background = background;
        this.scenarioDefinitions = Collections.unmodifiableList(scenarioDefinitions);
        this.comments = Collections.unmodifiableList(comments);
    }

    public List<ScenarioDefinition> getScenarioDefinitions() {
        return scenarioDefinitions;
    }

    public Background getBackground() {
        return background;
    }

    public String getLanguage() {
        return language;
    }

    public String getKeyword() {
        return keyword;
    }

    public String getName() {
        return name;
    }

    public String getDescription() {
        return description;
    }

    public List<Tag> getTags() {
        return tags;
    }

    public List<Comment> getComments() {
        return comments;
    }
}
