package com.outfit.ai.cloth_app.service;

import com.outfit.ai.cloth_app.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

/**
 * 코드 테이블 조회 서비스
 */
@Service
public class CodeService {
    private final CategoryRepository categoryRepository;
    private final ColorRepository colorRepository;
    private final MaterialRepository materialRepository;
    private final SeasonCodeRepository seasonCodeRepository;
    private final StyleCodeRepository styleCodeRepository;
    private final ItemTypeCodeRepository itemTypeCodeRepository;

    public CodeService(CategoryRepository categoryRepository,
                       ColorRepository colorRepository,
                       MaterialRepository materialRepository,
                       SeasonCodeRepository seasonCodeRepository,
                       StyleCodeRepository styleCodeRepository,
                       ItemTypeCodeRepository itemTypeCodeRepository) {
        this.categoryRepository = categoryRepository;
        this.colorRepository = colorRepository;
        this.materialRepository = materialRepository;
        this.seasonCodeRepository = seasonCodeRepository;
        this.styleCodeRepository = styleCodeRepository;
        this.itemTypeCodeRepository = itemTypeCodeRepository;
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getCategories() {
        return categoryRepository.findAll().stream()
                .map(c -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("category_id", c.getCategoryId());
                    map.put("category_name", c.getCategoryName());
                    return map;
                })
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getColors() {
        return colorRepository.findAll().stream()
                .map(c -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("color_id", c.getColorId());
                    map.put("color_name", c.getColorName());
                    return map;
                })
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getMaterials() {
        return materialRepository.findAll().stream()
                .map(m -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("material_id", m.getMaterialId());
                    map.put("material_name", m.getMaterialName());
                    return map;
                })
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getSeasons() {
        return seasonCodeRepository.findAll().stream()
                .map(s -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("season_id", s.getSeasonId());
                    map.put("season_name", s.getSeasonName());
                    return map;
                })
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getStyles() {
        return styleCodeRepository.findAll().stream()
                .map(s -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("style_id", s.getStyleId());
                    map.put("style_name", s.getStyleName());
                    return map;
                })
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getTypes() {
        return itemTypeCodeRepository.findAll().stream()
                .map(t -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("type_id", t.getItemTypeId());
                    map.put("type_name", t.getItemTypeName());
                    return map;
                })
                .collect(Collectors.toList());
    }
}
